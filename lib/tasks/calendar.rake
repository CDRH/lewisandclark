namespace :calendar do
  desc "create calendar HTML"

  def get_journals
    # pull the date information from rosie
    solr_url = CONFIG['solr_url']
    if solr_url
      $solr = RSolrCdrh::Query.new(solr_url, ["id", "date", "creators"])
      res = $solr.query({
        "qfield" => "lc_searchtype_s",
        "qtext" => "journal_file",
        # "rows" => 10
        "rows" => 1100
      })
      return res[:docs]
    end
  end

  def make_calendar_json journals
    js_obj = "dates = ["
    journals.each do |item|
      id = item["id"]
      date = item["date"]
      y, m, d = date.split("-")
      if date != ""
        item_data = %{ 
        {
          id: "#{id}",
          name: "#{id}",
          location: "Some place",
          startDate: new Date(#{y}, #{m}, #{d}),
          endDate: new Date(#{y}, #{m}, #{d}),
        },
        }
        js_obj += item_data
      else
        puts "no date match for #{id}"
      end
    end
    js_obj += "];"
    return js_obj
  end

  def write_to_file date_info
    File.open("dates.js", "w") do |file|
      file.write(date_info)
    end
  end

  task create: :environment do
    journals = get_journals
    date_info = make_calendar_json journals
    write_to_file date_info
  end

end
