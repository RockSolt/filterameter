Rails.application.routes.draw do
  resources :tasks, only: :index
  resources :activities, only: :index
  resources :projects, only: :index

  resources :legacy_projects, only: :index
  resources :active_activities, only: :index
  resources :active_tasks, only: :index
end
