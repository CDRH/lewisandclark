module ItemsHelper

  def any_facets_selected?
    selected = false
    for key in Facets.facet_list do
      if params.has_key?(key)
        selected = true
      end
    end
    return selected
  end

  def metadata(label, solr_ele, data, link_bool=true)
    if data
      html = "<li><strong>#{label}:</strong> "  # title
      data = data.class == Array ? data : [data]
      dataArray = data.map do |item|
        if link_bool
          search_params = { qfield: solr_ele, qtext: item }
          link_to item, search_path(search_params)
        else
          item
        end
      end
      html += dataArray.join(" | ")
      return html.html_safe
    end
  end

  def selected_class(selectedBool)
    return selectedBool ? "class='selected'" : ""
  end
end
