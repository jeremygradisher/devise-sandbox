Rails.application.routes.draw do
  devise_for :users, :controllers => { registrations: 'registrations' }
  get 'welcome/index'
  
  root 'welcome#index'
  
  #resources :users, :only => [:index, :show, :destroy]
  resources :users
  
  #devise_for :users, :controllers => { registrations: 'my_devise/registrations' }
end
