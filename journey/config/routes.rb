Rails.application.routes.draw do
  resources :users, controller: 'users', only: %i(new create)
  post '/signup', to: 'users#create'

  resource :session, controller: 'sessions', only: %i(create destroy)
  get    '/login',  to: 'sessions#new', as: :sign_in
  post   '/login',  to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy', as: :sign_out

  root 'home#show'

  get  'signup', to: 'users#new', as: :sign_up
  post   'session', to: 'sessions#create'

  resource :profile, only: %i(show edit update)
end
