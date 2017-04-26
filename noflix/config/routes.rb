Rails.application.routes.draw do
  resources :subtitles
  resources :reviews
  resources :directors
  resources :actors
  resources :episodes
  resources :series
  resources :seasons
  resources :articles
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: "home#index"
end
