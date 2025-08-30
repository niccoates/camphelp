Rails.application.routes.draw do
  root "campsites#index"
  resources :campsites, param: :slug do
    member do
      get "settings"
      get "settings/portal", to: "campsites#settings_portal", as: "settings_portal"
      delete "/", to: "campsites#destroy"
    end
  end

  # Explicitly specify the controller
  resource :account, only: [ :show, :update ], controller: "account"

  namespace :account do
    resource :password, only: [ :show, :update ]
  end
  resource :session
  resources :passwords, param: :token
  resource :sign_up
  get "up" => "rails/health#show", as: :rails_health_check
end
