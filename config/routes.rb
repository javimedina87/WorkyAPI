Rails.application.routes.draw do
  resources :users, :books

  post '/users/login', to: 'users#login'
  post '/users/register', to: 'users#register'

end
