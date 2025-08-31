class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  has_many :campsite_users, dependent: :destroy
    has_many :campsites, through: :campsite_users

    validates :stripe_customer_id, uniqueness: true, allow_nil: true

    def owned_campsites
      campsites.joins(:campsite_users).where(campsite_users: { is_owner: true })
    end

    def active_campsites
      campsites.where(subscription_status: ['trial', 'active'])
    end

    def suspended_campsites
      campsites.where(subscription_status: ['past_due', 'canceled', 'unpaid'])
    end

    def has_suspended_campsites?
      suspended_campsites.any?
    end

    def can_create_campsite?
      return false if has_suspended_campsites?
      return false if currently_in_trial?

      # If user has used trial but has no campsites, allow creation
      # (handles case where user deleted their trial campsite)
      return true if has_used_trial && campsites.empty?

      # If user has used trial and has active subscriptions, allow creation
      return true if has_used_trial && has_active_subscription?

      # If user hasn't used trial yet, allow creation
      return true unless has_used_trial

      false
    end

    def currently_in_trial?
      campsites.where(subscription_status: 'trial').any?
    end

    def has_active_subscription?
      campsites.where(subscription_status: 'active').any?
    end

    def trial_campsite
      campsites.find_by(subscription_status: 'trial')
    end
  end
