class CampsitesController < ApplicationController
  before_action :require_authentication
  before_action :set_campsite, only: [:show, :edit, :update, :settings, :settings_portal, :destroy]
  before_action :set_user_campsites, if: :show_navigation?
  before_action :ensure_owner, only: [:edit, :update, :settings, :settings_portal, :destroy]
  before_action :check_can_create_campsite, only: [:new, :create]

  def index
    @campsites = Current.user.campsites
  end

  def new
    @campsite = Campsite.new
  end

  def create
    @campsite = Campsite.new(campsite_params)

    # Set initial subscription status to avoid validation error
    @campsite.subscription_status = 'trial'

    if @campsite.save
      begin
        # Make the current user the owner
        @campsite.campsite_users.create!(user: Current.user, is_owner: true)

        # Create Stripe subscription (this will update the subscription details)
        StripeService.create_campsite_subscription(Current.user, @campsite)

        redirect_to campsite_path(@campsite.slug), notice: 'Campsite created successfully! Your 7-day trial has started.'
      rescue Stripe::StripeError => e
        # If Stripe fails, we need to clean up the campsite
        @campsite.destroy
        Rails.logger.error "Stripe subscription creation failed: #{e.message}"
        redirect_to new_campsite_path, alert: 'Unable to create campsite subscription. Please try again.'
      rescue => e
        # Handle any other errors
        @campsite.destroy
        Rails.logger.error "Campsite creation failed: #{e.message}"
        redirect_to new_campsite_path, alert: 'Unable to create campsite. Please try again.'
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @user_campsites = Current.user.campsites.order(:name)

    # Check if campsite is suspended
    if @campsite.suspended?
      render 'suspended' and return
    end
  end

  def edit
    if @campsite.suspended?
      redirect_to campsite_path(@campsite.slug), alert: 'Cannot edit suspended campsite.'
    end
  end

  def update
    if @campsite.suspended?
      redirect_to campsite_path(@campsite.slug), alert: 'Cannot update suspended campsite.'
      return
    end

    if @campsite.update(campsite_params)
      redirect_to settings_campsite_path(@campsite.slug), notice: 'Campsite updated successfully!'
    else
      render :settings, status: :unprocessable_entity
    end
  end

  # Settings actions
  def settings
    redirect_to_billing_if_suspended
  end

  def settings_portal
    redirect_to_billing_if_suspended
  end

  # Delete action
  def destroy
    campsite_name = @campsite.name

    begin
      # Cancel Stripe subscription if it exists
      if @campsite.stripe_subscription_id.present?
        StripeService.cancel_subscription(@campsite)
      end
    rescue Stripe::StripeError => e
      Rails.logger.error "Failed to cancel Stripe subscription: #{e.message}"
      # Continue with deletion even if Stripe cancellation fails
    end

    @campsite.destroy
    redirect_to new_campsite_path, notice: "#{campsite_name} has been successfully deleted."
  end

  private

  def set_user_campsites
    @user_campsites = Current.user.active_campsites.order(:name) if authenticated?
  end

  def set_campsite
    @campsite = Campsite.find_by!(slug: params[:slug])
  end

  def ensure_owner
    redirect_to root_path unless @campsite.campsite_users.exists?(user: Current.user, is_owner: true)
  end

  def check_can_create_campsite
    unless Current.user.can_create_campsite?
      if Current.user.has_suspended_campsites?
        redirect_to billing_path, alert: 'Please resolve suspended campsites before creating a new one.'
      elsif Current.user.currently_in_trial?
        redirect_to root_path, alert: 'You can only create one campsite during your trial period.'
      else
        redirect_to root_path, alert: 'Unable to create campsite at this time.'
      end
    end
  end

  def redirect_to_billing_if_suspended
    if @campsite.suspended?
      redirect_to billing_path, alert: 'This campsite is suspended. Please update your billing to continue.'
    end
  end

  def campsite_params
    params.require(:campsite).permit(:name, :about, :logo, :primary_colour,
                                   :open_from, :closed_from, :website,
                                   :contact_email, :contact_number)
  end
end
