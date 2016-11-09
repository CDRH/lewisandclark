module Facets

  @facet_info = {
    "category" => {
      "label" => "Category",
      "display" => true
    },
    "subCategory" => {
      "label" => "Sub Category",
      "display" => true
    },
    "lc_searchtype_s" => {
      "label" => "Part of Website",
      "display" => true
    },
    "creators" => {
      "label" => "Creator",
      "display" => true
    },
    "lc_index_combined_ss" => {
      "label" => "Combined Index",
      "display" => false
    },
    "people" => {
      "label" => "People",
      "display" => true
    },
    "lc_native_nation_ss" => {
      "label" => "Native Nation",
      "display" => true
    },
    "places" => {
      "label" => "Place",
      "display" => true
    },
    "lc_state_ss" => {
      "label" => "State",
      "display" => true
    },
    "source" => {
      "label" => "Source",
      "display" => true
    },
    "publisher" => {
      "label" => "Publisher",
      "display" => true
    }
  }

  def self.facet_info
    return @facet_info
  end

  def self.facet_list
    return @facet_info.keys
  end
end
