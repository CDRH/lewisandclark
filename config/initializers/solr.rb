CONFIG = YAML.load_file("#{Rails.root.to_s}/config/solr.yml")[Rails.env]

$solr = RSolrCdrh::Query.new(CONFIG['solr_url'])

JRN_FILE_COUNT = $solr.query({
  "q" => "lc_searchtype_s:journal_file",
  "fl" => "id",
  "rows" => 1,
})[:num_found]

ENTRY_COUNT = $solr.query({
  "q" => "lc_searchtype_s:journal_entry",
  "fl" => "id",
  "rows" => 1,
})[:num_found]

