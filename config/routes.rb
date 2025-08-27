Rails.application.routes.draw do
  root "campsites#index"

  resources :campsites, param: :slug do
  end

  resource :session
  resources :passwords, param: :token
  resource :sign_up

  get "up" => "rails/health#show", as: :rails_health_check
end
