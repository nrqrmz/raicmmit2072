class Message < ApplicationRecord
  belongs_to :challenge

  has_one_attached :file

  validate :file_size_validation
  validates :content, length: { minimum: 10, maximum: 1000 }, if: -> { role == "user" }

  MAX_FILE_SIZE_MB = 10

  private

  def file_size_validation
    if file.attached? && file.byte_size > MAX_FILE_SIZE_MB.megabytes
      errors.add(:file, "size must be less than #{MAX_FILE_SIZE_MB}MB")
    end
  end
end
