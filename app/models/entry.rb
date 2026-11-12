class Entry < ApplicationRecord
  belongs_to :category

  enum :kind, {
    income: "income",
    expense: "expense"
  }

  validates :title, :amount, :occurred_on, :kind, presence: true

  validates :amount, numericality: { greater_than: 0 }

  # limitado por conta do banco atual, quando migrar para POSTGRESQL, posso evoluir
  scope :filter_by_title, ->(search) { where("title LIKE ?", "%#{search}%") if search.present? }
  scope :filter_by_category, ->(category_id) { where(category_id: category_id) if category_id.present? }
  scope :filter_by_kind, ->(kind) { where(kind: kind) if kinds.key?(kind) }
end
