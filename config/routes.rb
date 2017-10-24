Rails.application.routes.draw do

  resources :voice_messages

  devise_for :users, controllers: { sessions: 'users/sessions' }

  resources :cases
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  #
  root to: 'cases#index'
end
