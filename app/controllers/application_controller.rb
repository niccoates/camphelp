class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  private

  def show_navigation?
    return false unless authenticated?

    # Don't show nav on these paths
    excluded_paths = [
      new_session_path,
      sign_up_path,
      new_campsite_path,
      campsites_path,
      root_path
    ]

    # Don't show nav if current path matches any excluded path
    !excluded_paths.include?(request.path)
  end

  helper_method :show_navigation?
end
