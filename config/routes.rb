Rails.application.routes.draw do
  root 'static#index', as: :home

  get 'about' => 'static#about', as: :about
  get 'journals' => 'static#journals', as: :journals
  get 'journals/about' => 'static#journals_about', as: :j_about
  get 'journals/calendar' => 'static#calendar', as: :calendar
  get 'journals/contents' => 'static#contents', as: :contents
  get 'map' => 'static#map', as: :map
  get 'multimedia' => 'static#multimedia', as: :multimedia
  get 'texts' => 'static#texts', as: :texts

  # images
  get 'images' => 'static#images', as: :images
  get 'images/maps' => 'static#images_maps', as: :images_maps
  get 'images/people_places' => 'static#images_people_places', as: :images_people_places
  get 'images/plants_animals' => 'static#images_plants_animals', as: :images_plants_animals

  # indices (facets for journal terms)
  get 'journals/index' => 'indices#index', as: :index
  get 'journals/index/native_nations' => 'indices#nations', as: :index_nations
  get 'journals/index/people' => 'indices#people', as: :index_people
  get 'journals/index/places' => 'indices#places', as: :index_places

  # items
  get 'search' => 'items#search', as: :search
  get 'item/:id' => 'items#show', as: :item,  :constraints => { :id => /[^\/]+/ }

  # errors
  match '/404', to: 'errors#not_found', via: :all
  match '/500', to: 'errors#server_error', via: :all
end
