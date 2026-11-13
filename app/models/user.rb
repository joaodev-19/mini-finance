class User < ApplicationRecord
  has_secure_password

  MAX_ACCOUNTS = 5

  validate :account_limit_not_reached, on: :create

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

  def self.register(attributes)
    transaction do
      if connection.adapter_name == "PostgreSQL"
        connection.execute(
          "SELECT pg_advisory_xact_lock(20261113)"
        )
      end

      create(attributes)
    end
  end

  private

  def account_limit_not_reached
    if User.count >= MAX_ACCOUNTS
      errors.add(:base, :account_limit_reached, limit: MAX_ACCOUNTS)
    end
  end
end
