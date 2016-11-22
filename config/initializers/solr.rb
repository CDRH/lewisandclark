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

ENTRY_DATE_FIRST = $solr.query({
  "fl" => "date",
  "q" => "*:*",
  "rows" => 1,
  "sort" => "lc_dateNotBefore_s asc",
})[:docs][0]['date'].split("-")

ENTRY_DATE_LAST = $solr.query({
  "fl" => "date",
  "q" => "*:*",
  "rows" => 1,
  "sort" => "lc_dateNotAfter_s desc",
})[:docs][0]['date'].split("-")

ENTRY_DATE_DISPLAY_FIRST = DateTime.new(
  ENTRY_DATE_FIRST[0].to_i,
  ENTRY_DATE_FIRST[1].to_i,
  ENTRY_DATE_FIRST[2].to_i)
.strftime("%b %d, %Y")

ENTRY_DATE_DISPLAY_LAST = DateTime.new(
  ENTRY_DATE_LAST[0].to_i,
  ENTRY_DATE_LAST[1].to_i,
  ENTRY_DATE_LAST[2].to_i)
.strftime("%b %d, %Y")

