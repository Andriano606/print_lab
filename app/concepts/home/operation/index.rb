class Home::Operation::Index < PrintLab::Operation::Base
  def perform!(**)
    SliceModelJob.perform_later(model_file_hashid: ModelFile.first.hashid)
  end
end
