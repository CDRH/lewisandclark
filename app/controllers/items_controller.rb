class ItemsController < ApplicationController

  def browse
    @page_type = "browse"
    facets = Facets.facet_list
    # TODO handle this in the future better
    # because some facets commented out in facets.rb
    @facets = $solr.get_facets({
      :"facet.sort" => "index",
      :"facet.limit" => "-1",
      }, facets)
  end

  def search
    @page_type = "search"
    search_and_facet
  end

  def show
    @page_type = "item"
    @item = $solr.get_item_by_id(params["id"])
    if @item
      url = @item["uriHTML"]
      begin
        @res = Net::HTTP.get(URI.parse(url)) if url
      rescue
        logger.error("Unable to parse url #{url}")
      end
    else
      # If you don't want a generic 404 page, you could handle this in the show.html.erb
      # view by using an else to detect @item
      raise ActionController::RoutingError.new('Not Found')
    end
  end


  private

  def search_and_facet
    # if no search terms, don't display search
    # if none filled in, display all results with asterisks
    params.delete("facet.field")  # why is this happening oh man
    options = create_search_options(params)
    @items = $solr.query(options)
    @total_pages = @items[:pages]
    @facets = $solr.get_facets(options)
  end

  def create_search_options(aParams)
    options = aParams.clone
    fq = []
    for key in Facets.facet_list do
      if options[key]
        fq << "#{key.to_s}:\"#{options[key]}\""
      end
    end
    options[:fq] = fq
    if options[:q] && !options[:sort]
      # if there is a query, then make sure score is the default sort
      options[:sort] = "score desc"
    end
    return options
  end

end
