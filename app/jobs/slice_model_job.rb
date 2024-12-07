class SliceModelJob < ApplicationJob
  queue_as :default

  def perform(model_file_hashid:)
    model_file = ModelFile.find_by_hashid(model_file_hashid)
    return unless model_file&.file&.attached?

    sanitized_file_name = sanitize_filename(model_file.file.filename.to_s)
    unique_file_name = "#{SecureRandom.uuid}-#{sanitized_file_name}"
    origin_file_path = Rails.root.join("tmp", "uploads", unique_file_name)
    sliced_file_name = unique_file_name.gsub(File.extname(unique_file_name), ".gcode")

    prepare_directory(origin_file_path.dirname)

    create_local_file(origin_file_path, model_file)

    if convert_to_gcode(origin_file_path.dirname, origin_file_path.basename, sliced_file_name)
      delete_tmp_files(origin_file_path, origin_file_path.dirname.join(sliced_file_name))
    else
      Rails.logger.error "G-code conversion failed for #{origin_file_path}"
    end
  end

  private

  def sanitize_filename(filename)
    filename.gsub(/[^a-zA-Z0-9_\-\.]/, "_")
  end

  def prepare_directory(directory_path)
    FileUtils.mkdir_p(directory_path) unless File.directory?(directory_path)
  end

  def create_local_file(origin_file_path, model_file)
    File.open(origin_file_path, "wb") do |file|
      file.write(model_file.file.download)
    end
  rescue => e
    Rails.logger.error "Failed to create local file at #{origin_file_path}: #{e.message}"
  end

  def convert_to_gcode(destination_folder_path, origin_file_name, sliced_file_name)
    docker_command = build_docker_command(destination_folder_path, origin_file_name, sliced_file_name)

    Rails.logger.info "Running Docker command: #{docker_command.join(' ')}"
    system(*docker_command)
  rescue => e
    Rails.logger.error "Error during G-code conversion: #{e.message}"
    false
  end

  def build_docker_command(folder_path, origin_file_name, sliced_file_name)
    escaped_folder_path = Shellwords.escape(folder_path.to_s)
    escaped_origin_file = Shellwords.escape(origin_file_name.to_s)
    escaped_sliced_file = Shellwords.escape(sliced_file_name.to_s)

    [
      "docker", "run", "--rm", "-it", "--platform", "linux/amd64",
      "-v", "#{escaped_folder_path}:/workspace",
      "keyglitch/docker-slic3r-prusa3d", "--export-gcode",
      "-o", "/workspace/#{escaped_sliced_file}",
      "/workspace/#{escaped_origin_file}"
    ]
  end

  def delete_tmp_files(*file_paths)
    file_paths.each do |file_path|
      File.delete(file_path) if File.exist?(file_path)
    rescue => e
      Rails.logger.error "Failed to delete temporary file #{file_path}: #{e.message}"
    end
  end
end
