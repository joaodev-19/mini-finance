class User < ApplicationRecord
  has_secure_password

  has_many :sessions, dependent: :destroy
  has_many :entries, dependent: :destroy
  has_many :categories, dependent: :restrict_with_error

  normalizes :email_address, with: ->(e) { e.strip.downcase }
end
