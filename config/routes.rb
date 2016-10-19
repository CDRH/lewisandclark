Rails.application.routes.draw do
  root 'static#index', as: :home
  get 'about' => 'static#about', as: :about

  #kmd's temp pages, will move around as necessary
  get 'map' => 'static#map', as: :map
  get 'multimedia' => 'static#multimedia', as: :multimedia
  get 'images' => 'static#images', as: :images
  get 'texts' => 'static#texts', as: :texts
  get 'journals' => 'static#journals', as: :journals
  get 'advanced_search' => 'static#advanced_search', as: :advanced_search
  get 'journals_index' => 'static#journals_index', as: :journals_index
  get 'journals_date' => 'static#journals_date', as: :journals_date
  get 'journals_toc' => 'static#journals_toc', as: :journals_toc
  get 'journals_about' => 'static#journals_about', as: :journals_about

  # documents
  get 'browse' => 'documents#browse', as: :browse
  get 'search' => 'documents#search', as: :search
  get 'doc/:id' => 'documents#show', as: :doc,  :constraints => { :id => /[^\/]+/ }

  # errors
  match '/404', to: 'errors#not_found', via: :all
  match '/500', to: 'errors#server_error', via: :all
end
