class Message < ApplicationRecord
  belongs_to :challenge

  has_one_attached :file
end
