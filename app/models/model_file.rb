class ModelFile < ApplicationRecord
  has_one_attached :file

  validate :acceptable_file_format

  def acceptable_file_format
    return unless file.attached?

    # Accept only certain formats
    accepted_formats = [ "application/vnd.ms-pki.stl",
                        "application/octet-stream",
                        "application/obj",
                        "application/xml",
                        "application/x-3mf",
                        "text/plain",
                        "application/x-tika-ooxml" ]

    unless accepted_formats.include? file.content_type
      errors.add(:file, "must be a valid STL, OBJ, AMF, 3MF, or G-code file")
    end
  end
end
