Rails.application.routes.draw do

  resources :voice_messages

  resources :white_listed_users

  resources :cases

  root to: 'cases#index'

  devise_for :users, controllers: { confirmations: 'confirmations', registrations: 'registrations' }

end
