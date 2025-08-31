class StripeService
  class << self
    def create_customer(user)
      customer = Stripe::Customer.create({
        email: user.email_address,
        name: user.name || user.email_address,
        metadata: {
          user_id: user.id
        }
      })

      user.update!(stripe_customer_id: customer.id)
      customer
    rescue Stripe::StripeError => e
      Rails.logger.error "Failed to create Stripe customer: #{e.message}"
      raise
    end

    def create_campsite_subscription(user, campsite)
      # Ensure user has a Stripe customer
      customer = if user.stripe_customer_id.present?
                   Stripe::Customer.retrieve(user.stripe_customer_id)
                 else
                   create_customer(user)
                 end

      # Create the subscription with trial
      subscription = Stripe::Subscription.create({
        customer: customer.id,
        items: [{
          price: price_id_for_campsite
        }],
        trial_period_days: 7,
        metadata: {
          campsite_id: campsite.id,
          user_id: user.id
        }
      })

      # Update campsite with subscription details
      trial_end_time = Time.at(subscription.trial_end)

      campsite.update!(
        stripe_subscription_id: subscription.id,
        subscription_status: 'trial',
        trial_ends_at: trial_end_time
      )

      # Mark user as having used their trial
      user.update!(has_used_trial: true)

      subscription
    rescue Stripe::StripeError => e
      Rails.logger.error "Failed to create Stripe subscription: #{e.message}"
      raise
    end

    def cancel_subscription(campsite)
      return unless campsite.stripe_subscription_id

      Stripe::Subscription.cancel(campsite.stripe_subscription_id)

      campsite.update!(
        subscription_status: 'canceled'
      )
    rescue Stripe::StripeError => e
      Rails.logger.error "Failed to cancel Stripe subscription: #{e.message}"
      raise
    end

    def create_customer_portal_session(user, return_url)
      return nil unless user.stripe_customer_id

      Stripe::BillingPortal::Session.create({
        customer: user.stripe_customer_id,
        return_url: return_url
      })
    rescue Stripe::StripeError => e
      Rails.logger.error "Failed to create customer portal session: #{e.message}"
      raise
    end

    private

    def price_id_for_campsite
      # You'll need to create this price in your Stripe dashboard
      # £60/year for campsite subscription
      Rails.application.credentials.dig(:stripe, :campsite_price_id) || 'price_1234567890'
    end
  end
end
