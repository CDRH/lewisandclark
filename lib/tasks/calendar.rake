namespace :calendar do
  desc "create calendar HTML"

  def get_journals
    # pull the date information from rosie
    solr_url = CONFIG['solr_url']
    fields = ["id", "lc_dateNotBefore_s", "lc_dateNotAfter_s", "creators"]
    if solr_url
      $solr = RSolrCdrh::Query.new(solr_url, )
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
      creators = item["creators"] ? item["creators"].join("; ") : "No creators"
      date1 = item["lc_dateNotBefore_s"]
      date2 = item["lc_dateNotAfter_s"]
      if date1 != "" && date2 != ""
        y1, m1, d1 = date1.split("-")
        y2, m2, d2 = date2.split("-")
        # javascript sucks at dates, so help it out
        m1 = m1.to_i - 1
        m2 = m2.to_i - 1
        item_data = %{ 
        {
          id: "#{id}",
          name: "#{id}",
          location: "#{creators}",
          startDate: new Date(#{y1}, #{m1}, #{d1}),
          endDate: new Date(#{y2}, #{m2}, #{d2}),
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
    File.open("app/assets/javascripts/calendar/dates.js", "w") do |file|
      file.write(date_info)
    end
  end

  task create: :environment do
    journals = get_journals
    date_info = make_calendar_json journals
    write_to_file date_info
  end

end
