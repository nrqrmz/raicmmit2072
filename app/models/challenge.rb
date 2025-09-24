class Challenge < ApplicationRecord
  has_many :messages, dependent: :destroy
  validates :name, :module, :content, presence: true
end
