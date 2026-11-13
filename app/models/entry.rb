class Entry < ApplicationRecord
  belongs_to :user
  belongs_to :category

  enum :kind, {
    income: "income",
    expense: "expense"
  }

  validate :category_belongs_to_user

  validates :title, :amount, :occurred_on, :kind, presence: true

  validates :amount, numericality: { greater_than: 0 }

  scope :filter_by_title, ->(search) {
    if search.present?
      term = sanitize_sql_like(search.strip.downcase)

      where(
        "LOWER(entries.title) LIKE ?",
        "%#{term}%"
      )
    end
  }
  scope :filter_by_category, ->(category_id) { where(category_id: category_id) if category_id.present? }
  scope :filter_by_kind, ->(kind) { where(kind: kind) if kinds.key?(kind) }

  private
    def category_belongs_to_user
      return if category.nil? || user.nil?

      if category.user_id != user_id
        errors.add(
          :category,
          "não pertence a este usuário"
        )
      end
    end
end
