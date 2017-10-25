Rails.application.routes.draw do

  resources :voice_messages

  resources :cases
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  #
  root to: 'cases#index'

  devise_for :users, controllers: { confirmations: 'confirmations', registrations: 'registrations' }

end
