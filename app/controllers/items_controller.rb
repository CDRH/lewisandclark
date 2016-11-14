class ItemsController < ApplicationController

  def browse
    @page_type = "browse"
    facets = Facets.facet_list
    # TODO handle this in the future better
    # because some facets commented out in facets.rb
    @facets = $solr.get_facets({
      "facet.sort" => "index",
      "facet.limit" => "-1",
      "fq" => ['lc_searchtype_s:(NOT "journal_file")']
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
    @search_bool = user_search? || params["all"] == "true"
    params.delete("facet.field")  # why is this happening oh man
    options = create_search_options(params)
    @items = $solr.query(options)
    @total_pages = @items[:pages]
    @facets = $solr.get_facets(options)
  end

  def create_search_options(aParams)
    options = ActionController::Parameters.new(aParams)
    # make sure that empty search terms go through okay
    if !options[:qtext].nil? && options[:qtext].empty?
      options.delete("qfield")
      options.delete("qtext")
      @search_bool = true
    end

    # filter queries (facets)
    fq = []
    for key in Facets.facet_list do
      if options[key]
        fq << "#{key.to_s}:\"#{options[key]}\""
      end
    end
    # if lc_searchtype_s "journal file" specifically selected (unlikely),
    # then allow through, otherwise always omit from search
    if options["lc_searchtype_s"] != "journal_file"
      fq << 'lc_searchtype_s:(NOT "journal_file")'
    end
    options[:fq] = fq

    # date search
    date_from = format_date(options["date_from"], ["1803", "01", "01"])
    date_to = format_date(options["date_to"], ["1806", "12", "31"])
    options.delete("date_from")
    options.delete("date_to")
    if !options["date_from"].blank? || !options["date_to"].blank?
      options[:fq] << "lc_dateNotAfter_s:[#{date_from} TO #{date_to}]"
    end

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

  def user_search?
    # uses the view helper function "any_facets_selected?"
    has_facets = view_context.any_facets_selected?
    has_query = !params["qtext"].blank?
    has_sort = !params["sort"].blank?
    has_page = !params["page"].blank?
    return has_facets || has_query || has_sort || has_page
  end
end
