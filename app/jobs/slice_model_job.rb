class SliceModelJob < ApplicationJob
  queue_as :default

  SLICING_PROGRESS_CHANNEL = "slicing_progress_channel"

  def perform(model_file_hashid:)
    model_file = ModelFile.find_by_hashid(model_file_hashid)
    return unless model_file&.file&.attached?

    sanitized_file_name = sanitize_filename(model_file.file.filename.to_s)
    unique_file_name = "#{SecureRandom.uuid}-#{sanitized_file_name}"
    origin_file_path = Pathname.new("/workspace/#{unique_file_name}")
    sliced_file_name = unique_file_name.gsub(File.extname(unique_file_name), ".gcode")

    create_local_file(origin_file_path, model_file)

    unless convert_to_gcode(origin_file_path.basename.to_s, sliced_file_name)
      Rails.logger.error "G-code conversion failed for #{origin_file_path}"
    end
  end

  private

  def sanitize_filename(filename)
    filename.gsub(/[^a-zA-Z0-9_\-\.]/, "_")
  end

  def create_local_file(origin_file_path, model_file)
    File.open(origin_file_path, "wb") do |file|
      file.write(model_file.file.download)
    end
  rescue => e
    Rails.logger.error "Failed to create local file at #{origin_file_path}: #{e.message}"
  end

  def convert_to_gcode(origin_file_name, sliced_file_name)
    docker_command = build_docker_command(origin_file_name, sliced_file_name)
    Rails.logger.info "Running Docker command: #{docker_command.join(' ')}"

    IO.popen(docker_command, err: [:child, :out]) do |io|
      io.each_line do |line|
        Rails.logger.info line.strip # Log the line for debugging
        handle_progress(line.strip) # Parse progress and handle it
      end
    end

    $?.success?
  rescue => e
    Rails.logger.error "Error during G-code conversion: #{e.message}"
    false
  end

  def handle_progress(line)
    if line.match?(/^\d+ => /) # Matches lines like "20 => Generating perimeters"
      percentage = line.split("=>").first.strip.to_i
      Rails.logger.info "Slicing progress: #{percentage}%"
      ActionCable.server.broadcast(SLICING_PROGRESS_CHANNEL, { progress: percentage })
    elsif line.include?("Detected print stability issues:")
      Rails.logger.warn "Slicing warning: #{line}"
      ActionCable.server.broadcast(SLICING_PROGRESS_CHANNEL, { warning: line })
    elsif line.include?("Slicing result exported")
      Rails.logger.info "Slicing completed successfully."
      ActionCable.server.broadcast(SLICING_PROGRESS_CHANNEL, { status: "completed" })
    end
  end

  def build_docker_command(origin_file_name, sliced_file_name)
    [
      "docker", "run", "--rm", "-v", "/workspace:/workspace",
      "keyglitch/docker-slic3r-prusa3d", "--export-gcode",
      "-o", "/workspace/#{Shellwords.escape(sliced_file_name)}",
      "/workspace/#{Shellwords.escape(origin_file_name)}"
    ]
  end
end
