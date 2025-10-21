Rails.application.routes.draw do
  resources :user_stocks
  devise_for :users
  root 'welcome#index' # Root route for homepage
  get 'my_portfolio', to: 'users#my_portfolio'
  get 'search_stock', to: 'stocks#search'
end
