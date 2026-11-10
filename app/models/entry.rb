class Entry < ApplicationRecord
  belongs_to :category

  enum :kind, {
    income: "income",
    expense: "expense"
  }

  validates :title, :amount, :occurred_on, :kind, presence: true

  validates :amount, numericality: { greater_than: 0 }
end
