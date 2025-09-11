Rails.application.routes.draw do
  resources :users, controller: "users", only: [ :new, :create ]
  post "/signup", to: "users#create"

  resource :session, controller: "sessions", only: [ :create, :destroy ]
  get    "/login",  to: "sessions#new",     as: :sign_in
  post   "/login",  to: "sessions#create"
  delete "/logout", to: "sessions#destroy", as: :sign_out


  resource :profile, only: %i(show edit update)
end
