class BillingController < ApplicationController
  before_action :require_authentication

  def show
    redirect_to customer_portal_path
  end

  def customer_portal
    return_url = campsite_url(params[:campsite_slug]) if params[:campsite_slug]
    return_url ||= root_url

    session = StripeService.create_customer_portal_session(Current.user, return_url)

    if session
      redirect_to session.url, allow_other_host: true
    else
      redirect_to root_path, alert: 'Unable to access billing portal.'
    end
  rescue Stripe::StripeError => e
    redirect_to root_path, alert: 'Unable to access billing portal.'
  end
end
