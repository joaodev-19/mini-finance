class Category < ApplicationRecord
  has_many :entries, dependent: :restrict_with_error

  validates :name, presence: true
  validates :name, uniqueness: true
end
