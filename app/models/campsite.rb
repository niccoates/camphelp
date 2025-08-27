# app/models/campsite.rb
class Campsite < ApplicationRecord
  has_many :campsite_users, dependent: :destroy
  has_many :users, through: :campsite_users

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :contact_email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true

  before_validation :generate_slug, if: :name_changed?

  def owner
    campsite_users.find_by(is_owner: true)&.user
  end

  private

  def generate_slug
    self.slug = name.to_s.parameterize
  end
end
