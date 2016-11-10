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

  def facet_sort_selected(button, sort_type)
    # if the button matches the selected sort, made primary
    # default to "alphabetical" if there is no sort selected
    selected = button == sort_type
    selected = true if button == "index" && sort_type.nil?
    return selected ? "btn-primary" : "btn-default"
  end

  def metadata(label, solr_ele, data, link_bool=true)
    if data
      html = "<li><strong>#{label}:</strong> "  # title
      data = data.class == Array ? data : [data]
      dataArray = data.map do |item|
        if link_bool
          search_params = { qfield: solr_ele, qtext: item }
          link_to item
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

  def user_search?
    return any_facets_selected? || !params["qtext"].blank?
  end

end
