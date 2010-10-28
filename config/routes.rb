Cleantogether::Application.routes.draw do
  resources :geo_locations
  resources :facebook_users do
  
  
      resources :stories
  end

  resource :session
  match '/' => 'home#index', :as => :home
  match '/logout' => 'authorize#logout', :as => :logout
  match '/authorize' => 'authorize#new_facebook', :as => :auth_start
  match '/authorize/callback' => 'authorize#facebook_callback', :as => :auth_callback
  match '/:controller(/:action(/:id))'
end
