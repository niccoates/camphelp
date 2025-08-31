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

  SUBSCRIPTION_STATUSES = %w[trial active past_due canceled unpaid].freeze

   validates :subscription_status, inclusion: { in: SUBSCRIPTION_STATUSES }
   validates :stripe_subscription_id, uniqueness: true, allow_nil: true

   scope :active, -> { where(subscription_status: ['trial', 'active']) }
   scope :suspended, -> { where(subscription_status: ['past_due', 'canceled', 'unpaid']) }
   scope :in_trial, -> { where(subscription_status: 'trial') }

   def trial?
     subscription_status == 'trial'
   end

   def active?
     subscription_status == 'active'
   end

   def suspended?
     %w[past_due canceled unpaid].include?(subscription_status)
   end

   def trial_days_remaining
     return 0 unless trial? && trial_ends_at

     days_left = ((trial_ends_at - Time.current) / 1.day).ceil
     [days_left, 0].max
   end

   def trial_expired?
     trial? && trial_ends_at && trial_ends_at < Time.current
   end

  private

  def generate_slug
    self.slug = name.to_s.parameterize
  end

end
