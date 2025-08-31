Rails.application.configure do
  config.stripe = {
    publishable_key: Rails.application.credentials.dig(:stripe, :publishable_key),
    secret_key: Rails.application.credentials.dig(:stripe, :secret_key),
    webhook_secret: Rails.application.credentials.dig(:stripe, :webhook_secret)
  }
end

Stripe.api_key = Rails.application.config.stripe[:secret_key]
