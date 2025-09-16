Rails.application.routes.draw do
  resources :registrations, only: %i(new create)
  get '/signup', to: 'registrations#new', as: :sign_up

  resource :session, only: %i(create destroy)
  get '/login', to: 'sessions#new', as: :sign_in
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy', as: :sign_out

  resource :profile, only: %i(show edit update)
  resources :passwords, only: %i(new create), controller: 'clearance/passwords'
  resource :password, only: %i(edit update), controller: 'clearance/passwords'

  root 'home#show'
end
