Rails.application.routes.draw do
  resources :tasks, only: :index
  resources :activities, only: :index
  resources :projects, only: :index
end
