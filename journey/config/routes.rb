Rails.application.routes.draw do
  # Sign-up only (no sessions/routes for sign-in in this story)
  resources :users, controller: "users", only: [ :new, :create ]
  get  "/signup", to: "users#new",    as: :sign_up
  post "/signup", to: "users#create"

  root "home#show"
end
