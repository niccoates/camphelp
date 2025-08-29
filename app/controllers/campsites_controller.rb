# app/controllers/campsites_controller.rb
class CampsitesController < ApplicationController
  before_action :require_authentication
  before_action :set_campsite, only: [:show, :edit, :update, :settings, :settings_portal, :destroy]
  before_action :set_user_campsites, if: :show_navigation?
  before_action :ensure_owner, only: [:edit, :update, :settings, :settings_portal, :destroy]

  def index
     @campsites = Current.user.campsites
   end

  def new
    @campsite = Campsite.new
  end

  def create
    @campsite = Campsite.new(campsite_params)
    if @campsite.save
      # Make the current user the owner
      @campsite.campsite_users.create!(user: Current.user, is_owner: true)
      redirect_to campsite_path(@campsite.slug), notice: 'Campsite created successfully!'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @user_campsites = Current.user.campsites.order(:name)
  end

  def edit
  end

  def update
    if @campsite.update(campsite_params)
      redirect_to settings_campsite_path(@campsite.slug), notice: 'Campsite updated successfully!'
    else
      render :settings, status: :unprocessable_entity
    end
  end

  # Settings actions
  def settings
    # This will render the main campsite settings tab
  end

  def settings_portal
    # This will render the portal settings tab (placeholder for now)
  end

  # Delete action
  def destroy
    campsite_name = @campsite.name
    @campsite.destroy
    redirect_to new_campsite_path, notice: "#{campsite_name} has been successfully deleted."
  end

  private

  def set_user_campsites
    @user_campsites = Current.user.campsites.order(:name) if authenticated?
  end

  def set_campsite
    @campsite = Campsite.find_by!(slug: params[:slug])
  end

  def ensure_owner
    redirect_to root_path unless @campsite.campsite_users.exists?(user: Current.user, is_owner: true)
  end

  def campsite_params
    params.require(:campsite).permit(:name, :about, :logo, :primary_colour,
                                   :open_from, :closed_from, :website,
                                   :contact_email, :contact_number)
  end
end
