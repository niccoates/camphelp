Rails.application.routes.draw do
  root "campsites#index"

  resources :campsites, param: :slug do
    member do
      get 'settings'
      get 'settings/portal', to: 'campsites#settings_portal', as: 'settings_portal'
      delete '/', to: 'campsites#destroy' # This allows DELETE /campsites/:slug
    end
  end

  resource :session
  resources :passwords, param: :token
  resource :sign_up

  get "up" => "rails/health#show", as: :rails_health_check
end
