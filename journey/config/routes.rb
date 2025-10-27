Rails.application.routes.draw do
  resource :profile, only: %i(show edit update)
  resources :users, only: %i(new create), controller: 'users'
  scope '(:locale)', locale: /en|de/ do
    resources :users, only: %i(new create)
    get 'signup', to: 'users#new'
    post 'signup', to: 'users#create'

    get 'login', to: 'sessions#new', as: :login
    post 'login', to: 'sessions#create'
    delete 'logout', to: 'sessions#destroy', as: :logout
    get '/sign_up', to: 'users#new', as: :sign_up

    resources :passwords, only: %i(new create), controller: 'clearance/passwords'
    resource :password, only: %i(edit update), controller: 'clearance/passwords'

    resource :profile, only: %i(show update)

    namespace :settings do
      resource :password, only: %i(show update)
    end

    resources :journal_entries

    root 'home#show'
  end
end
