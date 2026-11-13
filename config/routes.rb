Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token

  resource :registration, only: %i[new create]

  get "dashboard/index"
  root "entries#index"

  resources :categories
  resources :entries

  get "up" => "rails/health#show", as: :rails_health_check
end
