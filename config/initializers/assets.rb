# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path
# Add Yarn node_modules folder to the asset load path.
Rails.application.config.assets.paths << Rails.root.join('node_modules')

# items/map
Rails.application.config.assets.precompile += %w(
  leaflet.js
  leaflet.scss
  map.js
))

# items/search
Rails.application.config.assets.precompile += %w(
  search.js
)

# items/show
Rails.application.config.assets.precompile += %w(
  ekko-lightbox.min.js
  item.js
)

# static/calendar
Rails.application.config.assets.precompile += %w(
  bootstrap-year-calendar.min.js
  calendar.css
  calendar/calendar.js
  calendar/dates.js
)
