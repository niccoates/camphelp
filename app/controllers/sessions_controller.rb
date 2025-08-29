class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_url, alert: "Try again later." }

  def new
  end

  def create
    if user = User.authenticate_by(params.permit(:email_address, :password))
      start_new_session_for user
      redirect_to after_authentication_url(user)
    else
      redirect_to new_session_path, alert: "Try another email address or password."
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path
  end

  private

  def after_authentication_url(user)
    case user.campsites.count
    when 0
      new_campsite_path  # Changed from root_path
    when 1
      campsite = user.campsites.first
      campsite_path(campsite.slug)
    else
      campsites_path  # Changed from root_path to show campsite list
    end
  end
end
