Rails.application.routes.draw do
  root 'static#index', as: :home
  get 'about' => 'static#about', as: :about

  #kmd's temp pages, will move around as necessary
  get 'map' => 'static#map', as: :map
  get 'multimedia' => 'static#multimedia', as: :multimedia
  get 'images' => 'static#images', as: :images
  get 'images_maps' => 'static#images_maps', as: :images_maps
  get 'images_people_places' => 'static#images_people_places', as: :images_people_places
  get 'images_plants_animals' => 'static#images_plants_animals', as: :images_plants_animals
  get 'texts' => 'static#texts', as: :texts
  get 'journals' => 'static#journals', as: :journals
  get 'advanced_search' => 'static#advanced_search', as: :advanced_search
  get 'journals_date' => 'static#journals_date', as: :j_date
  get 'journals_toc' => 'static#journals_toc', as: :j_toc
  get 'journals_about' => 'static#journals_about', as: :j_about

  # items
  get 'browse' => 'items#browse', as: :browse
  get 'journals_index' => 'items#index', as: :j_index
  get 'journals_index/nations' => 'items#index_nations', as: :j_index_nations
  get 'journals_index/people' => 'items#index_people', as: :j_index_people
  get 'journals_index/places' => 'items#index_places', as: :j_index_places
  get 'search' => 'items#search', as: :search
  get 'item/:id' => 'items#show', as: :item,  :constraints => { :id => /[^\/]+/ }

  # errors
  match '/404', to: 'errors#not_found', via: :all
  match '/500', to: 'errors#server_error', via: :all
end
