class PrintLab::Component::Dropzone < PrintLab::Component::Base
  def initialize(path:, **)
    @path = path
    @instruction = "Drop files here or click to upload"
  end
end
