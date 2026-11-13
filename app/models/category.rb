class Category < ApplicationRecord
  belongs_to :user
  has_many :entries, dependent: :restrict_with_error

  validates :name, presence: true
  validates :name, uniqueness: { scope: :user_id }
end
