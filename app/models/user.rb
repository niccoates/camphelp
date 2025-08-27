class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  has_many :campsite_users, dependent: :destroy
  has_many :campsites, through: :campsite_users

  def owned_campsites
    campsites.joins(:campsite_users).where(campsite_users: { is_owner: true })
  end
end
