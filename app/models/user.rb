class User < ApplicationRecord
  has_secure_password

  has_many :sessions, dependent: :destroy
  has_many :entries, dependent: :destroy
  has_many :categories, dependent: :restrict_with_error

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  after_create :ensure_default_categories!

  validates :email_address, presence: true, uniqueness: { case_sensitive: false }
  validates :password, length: { minimum: 8 }, if: -> { password.present? }

  def ensure_default_categories!
    Category::DEFAULT_NAMES.each do |name|
      categories.find_or_create_by!(name: name)
    end
  end
end
