class Category < ApplicationRecord
  DEFAULT_NAMES = [
    "Alimentação",
    "Transporte",
    "Moradia",
    "Saúde",
    "Educação",
    "Lazer",
    "Compras",
    "Trabalho",
    "Rendimentos"
  ].freeze

  belongs_to :user
  has_many :entries, dependent: :restrict_with_error

  validates :name, presence: true
  validates :name, uniqueness: { scope: :user_id }
end
