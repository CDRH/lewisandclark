class IndicesController < ApplicationController
  def index
    index_facets("all")
    @selection = "all"
  end

  def nations
    index_facets("nations")
    @selection = "nations"
    render "index"
  end

  def people
    index_facets("people")
    @selection = "people"
    render "index"
  end

  def places
    index_facets("places")
    @selection = "places"
    render "index"
  end

  private

  def get_index_field(aField)
    field = aField
    if field.nil?
      field = "lc_index_combined_ss"
    elsif field == "all"
      field = "lc_index_combined_ss"
    elsif field == "nations"
      field = "lc_native_nation_ss"
    end
    return field
  end

  # index_facets returns the results to display for the journal indexes
  # of people, native nations, places, etc
  def index_facets(aField)
    @page_type = "index"
    params.permit!
    options = {}
    field = get_index_field(aField)
    # NOTE:  The below is commented out because the rsolr_cdrh
    # gem does not currently return the total number of facet result pages
    # options["facet.offset"] = params["page"].to_i*20
    options["facet.sort"] = params["sort"]
    options["facet.field"] = field
    options["facet.limit"] = "-1"
    options["qfield"] = "lc_searchtype_s"
    options["qtext"] = "journal_entry"
    facet_res = $solr.get_facets(options, field)
    @facets = facet_res[field]
    @field = field
    return @facets
  end
end
