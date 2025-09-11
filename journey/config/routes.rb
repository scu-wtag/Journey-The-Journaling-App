Rails.application.routes.draw do
  root 'home#show'

  # Sign up
  get  'signup', to: 'users#new', as: :sign_up
  post 'users',  to: 'users#create'

  # Sign in/out (Custom SessionsController)
  get    'login', to: 'sessions#new', as: :sign_in
  post   'session', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy', as: :sign_out

  resource :profile, only: %i(show edit update)
end
