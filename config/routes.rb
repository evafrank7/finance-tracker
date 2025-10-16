Rails.application.routes.draw do
  devise_for :users
  root 'welcome#index' # Root route for homepage
end
