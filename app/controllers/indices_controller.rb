class IndicesController < ApplicationController
  def index
    @title = "Index of All Names"
    @description = ""
    index_facets("all")
  end

  def nations
    @title = "Index of Native Nations"
    @description = ""
    index_facets("nations")

    render "index"
  end

  def people
    @title = "Index of People"
    @description = ""
    index_facets("people")

    render "index"
  end

  def places
    @title = "Index of Places"
    @description = ""
    index_facets("places")

    render "index"
  end



  private

  def get_index_field(aField)
    field = aField

    if field.nil? || field == "all"
      field = "lc_index_combined_ss"
    elsif field == "nations"
      field = "lc_native_nation_ss"
    end

    return field
  end

  # index_facets returns the results to display for the journal indexes
  # of people, native nations, places, etc
  def index_facets(aField)
    @field = get_index_field(aField)
    @page_type = "index"
    @selection = aField

    params.permit!

    options = {}
    options["facet.field"] = @field
    options["facet.limit"] = "-1"
    # NOTE:  The below is commented out because the rsolr_cdrh
    # gem does not currently return the total number of facet result pages
    # options["facet.offset"] = params["page"].to_i*20
    options["facet.sort"] = params["sort"]
    options["qfield"] = "lc_searchtype_s"
    options["qtext"] = "journal_entry"

    @facets = $solr.get_facets(options, @field)[@field]
  end
end
