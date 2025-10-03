Rails.application.routes.draw do
  get 'profiles/show'
  get 'profiles/edit'
  get 'profiles/update'
  resource :profile, only: %i(show edit update)
  scope '(:locale)', locale: /en|de/ do
    resources :users, only: %i(new create)
    get '/signup', to: 'users#new', as: :sign_up
    post '/signup', to: 'users#create'

    get '/sign_in', to: 'sessions#new', as: :sign_in
    post '/sign_in', to: 'sessions#create'
    delete '/sign_out', to: 'sessions#destroy', as: :sign_out

    resource :session, only: %i(new create destroy), controller: 'sessions'
    get '/login', to: 'sessions#new', as: :login
    post '/login', to: 'sessions#create'
    delete '/logout', to: 'sessions#destroy', as: :logout

    resources :passwords, only: %i(new create), controller: 'clearance/passwords'
    resource :password, only: %i(edit update), controller: 'clearance/passwords'

    resource :profile, only: %i(show edit update)

    resource :profile, only: %i(show update)

    namespace :settings do
      resource :password, only: %i(show update)
    end
    resource :profile, only: %i(show edit update)

    root 'home#show'
  end
end
