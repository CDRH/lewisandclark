class ItemsController < ApplicationController

  def browse
    @page_type = "browse"
    facets = Facets.facet_list
    # TODO handle this in the future better
    # because some facets commented out in facets.rb
    @facets = $solr.get_facets({
      "facet.sort" => "index",
      "facet.limit" => "-1",
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
    # make sure that empty search terms go through okay
    if !options[:qtext].nil? && options[:qtext].empty?
      options[:qtext] = "*"
    end

    # filter queries (facets)
    fq = []
    for key in Facets.facet_list do
      if options[key]
        fq << "#{key.to_s}:\"#{options[key]}\""
      end
    end
    options[:fq] = fq

    # date search
    date_from = format_date(options["date_from"], ["1803", "01", "01"])
    date_to = format_date(options["date_to"], ["1806", "12", "31"])
    options.delete("date_from")
    options.delete("date_to")
    options[:fq] << "lc_dateNotAfter_s:[#{date_from} TO #{date_to}]"

    # sort
    if (options[:q] || options[:qtext]) && !options[:sort]
      # if there is a query, then make sure score is the default sort
      options[:sort] = "score desc"
    end
    return options
  end

  def format_date(date_params, default_date)
    y, m, d = date_params
    y = default_date[0] if y.blank?
    m = default_date[1] if m.blank?
    d = default_date[2] if d.blank?
    return "#{y}-#{m}-#{d}"
  end
end
