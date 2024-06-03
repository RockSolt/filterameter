Rails.application.routes.draw do
  resources :tasks, only: :index
  resources :activities, only: :index
  resources :projects, only: :index

  resources :brands, only: :index
  resources :shirts
  resources :vendors, only: :index
end
