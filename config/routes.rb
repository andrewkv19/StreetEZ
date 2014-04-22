StreetEZ::Application.routes.draw do

  root to: "rentals#home"

  resources :users, only: [:new, :create, :show]

  resource :session, only: [:new, :create, :destroy]

  resources :rentals, only: [:new, :create, :index, :show, :edit, :update, :destroy]

  resources :saved_rentals, only: [:create, :destroy]

end
