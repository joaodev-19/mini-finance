class Category < ApplicationRecord
  has_many :entries, dependent: :restrict_with_error
end
