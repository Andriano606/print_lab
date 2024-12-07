class ModelFile::Operation::Create < PrintLab::Operation::Base
  def perform!(params:, **)
    self.model = OpenStruct.new(model_files: [])

    params[:file].each do |key, file|
      model_file = ModelFile.new(file: file)

      if model_file.save
        self.model.model_files << model_file
        add_notice("#{file.original_filename} uploaded successfully. ")
      else
        add_error(:base, "#{file.original_filename} failed to upload. ")
      end
    end
  end
end
