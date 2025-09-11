Rails.application.routes.draw do
  resources :users, controller: 'users', only: [ :new, :create ]
  get  '/signup', to: 'users#new',    as: :sign_up
  post '/signup', to: 'users#create'

  root 'home#show'
end
