Rails.application.routes.draw do
  resources :users, :books

  post '/users/hola', to: 'users#hola'
  post '/users/jwt', to: 'users#jwt'



  post '/users/login', to: 'users#login'
  post '/users/register', to: 'users#register'

end
