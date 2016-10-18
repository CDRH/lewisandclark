CONFIG = YAML.load_file("#{Rails.root.to_s}/config/solr.yml")[Rails.env]
