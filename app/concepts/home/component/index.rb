class Home::Component::Index < PrintLab::Component::Base
  def initialize(**)
    SliceModelJob.perform_later(model_file_hashid: ModelFile.first.hashid)
  end
end
