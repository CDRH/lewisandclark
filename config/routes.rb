Rails.application.routes.draw do
  root 'static#index', as: :home
  get 'about' => 'static#about', as: :about

  # documents
  get 'browse' => 'documents#browse', as: :browse
  get 'search' => 'documents#search', as: :search
  get 'doc/:id' => 'documents#show', as: :doc,  :constraints => { :id => /[^\/]+/ }

  # errors
  match '/404', to: 'errors#not_found', via: :all
  match '/500', to: 'errors#server_error', via: :all
end
