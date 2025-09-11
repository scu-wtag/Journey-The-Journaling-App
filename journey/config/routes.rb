Rails.application.routes.draw do
  scope '(:locale)', locale: /en|de/ do
    resources :registrations, only: %i(new create)
    get '/signup', to: 'registrations#new', as: :sign_up

    resources :users, only: %i(new create)
  resources :users, controller: 'users', only: %i(new create)
  get  '/signup', to: 'users#new', as: :sign_up
  post '/signup', to: 'users#create'

  resource :session, controller: 'sessions', only: %i(create destroy)
  get    '/login',  to: 'sessions#new', as: :sign_in
  post   '/login',  to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy', as: :sign_out

  root 'home#show'

  # Sign up
  get  'signup', to: 'users#new', as: :sign_up
  post 'users',  to: 'users#create'

    resource :session, only: %i(create destroy)
    get '/login', to: 'sessions#new', as: :sign_in
    post '/login', to: 'sessions#create'
    delete '/logout', to: 'sessions#destroy', as: :sign_out

    resources :passwords, only: %i(new create), controller: 'clearance/passwords'
    resource :password, only: %i(edit update), controller: 'clearance/passwords'

    resource :profile, only: %i(show edit update)

    root 'home#show'
  end
end
