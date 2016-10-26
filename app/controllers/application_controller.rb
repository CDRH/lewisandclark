class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  solr_url = CONFIG['solr_url']
  if solr_url
    $solr = RSolrCdrh::Query.new(solr_url, Facets.facet_list)
    $solr.set_default_query_params({
      "sort" => "score desc",
      "hl" => "true",
      "hl.fragsize" => "100",
      "rows" => 50
      })
    $solr.set_default_facet_params({
      "facet.limit" => "20",
      "facet.mincount" => "1",
      "facet.sort" => "count"     # sort by result number
      # "facet.sort" => "index"  # sort by first letter
      })
  else
    raise "No Solr URL found for project, cannot continue!"
  end
end
