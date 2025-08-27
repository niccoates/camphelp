# app/controllers/campsites_controller.rb
class CampsitesController < ApplicationController
  before_action :require_authentication
  before_action :set_campsite, only: [:show, :edit, :update]
  before_action :ensure_owner, only: [:edit, :update]

  def index
    @campsites = Campsite.all
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
  end

  def edit
  end

  def update
    if @campsite.update(campsite_params)
      redirect_to @campsite, notice: 'Campsite updated successfully!'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_campsite
    @campsite = Campsite.find_by!(slug: params[:slug])
  end

  def ensure_owner
    redirect_to root_path unless @campsite.owner == Current.user
  end

  def campsite_params
    params.require(:campsite).permit(:name, :about, :logo, :primary_colour,
                                   :open_from, :closed_from, :website,
                                   :contact_email, :contact_number)
  end
end
