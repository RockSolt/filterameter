Rails.application.routes.draw do
  resources :brands, only: :index
  resources :shirts
  resources :vendors, only: :index
end
