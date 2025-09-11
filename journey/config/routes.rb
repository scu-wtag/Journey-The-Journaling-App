Rails.application.routes.draw do
  resources :users, controller: "users", only: [ :new, :create ]
  get  "/signup", to: "users#new",    as: :sign_up
  post "/signup", to: "users#create"

  resource :session, controller: "sessions", only: [ :create, :destroy ]
  get    "/login",  to: "sessions#new",     as: :sign_in
  post   "/login",  to: "sessions#create"
  delete "/logout", to: "sessions#destroy", as: :sign_out

  root 'home#show'
end
