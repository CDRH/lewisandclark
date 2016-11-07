require "#{Rails.root}/lib/cdrh/rewrite"

Rails.application.config.middleware.insert(0, "CDRH::Rewrite")

