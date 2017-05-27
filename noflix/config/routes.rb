Rails.application.routes.draw do
  resources :tv_shows
  resources :subtitles
  resources :reviews
  resources :directors
  resources :actors
  resources :episodes
  resources :seasons
  resources :articles
  # registrations para agregar nombre al registro de usuarios
  devise_for :users, :controllers => { registrations: 'registrations' }
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: "home#index"
end
