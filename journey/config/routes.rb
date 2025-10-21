Rails.application.routes.draw do
  scope '(:locale)', locale: /en|de/ do
    get '/signup', to: 'users#new', as: :sign_up
    post '/signup', to: 'users#create'
    get '/login', to: 'sessions#new', as: :login
    post '/login', to: 'sessions#create'
    delete '/logout', to: 'sessions#destroy', as: :logout

    resources :users, only: %i(new create)

    resources :passwords, only: %i(new create), controller: 'clearance/passwords'
    resource :password, only: %i(edit update), controller: 'clearance/passwords'

    namespace :settings do
      resource :password, only: %i(show update)
    end

    resource :profile, only: %i(show update)

    resources :journal_entries

    root 'home#show'
  end
end
