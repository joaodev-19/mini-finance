Rails.application.routes.draw do
  get "dashboard/index"
  root "entries#index"
  resources :categories
  resources :entries

  get "up" => "rails/health#show", as: :rails_health_check
end
