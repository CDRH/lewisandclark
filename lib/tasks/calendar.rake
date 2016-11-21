namespace :calendar do
  desc "create calendar HTML"

  DATA_FILE="app/assets/javascripts/calendar/dates.js"
  # SOLR_URL set within task create, as CONFIG comes from :environment

  def get_journals
    # pull the date information from Solr
    fields = %w{creators id lc_dateNotAfter_s lc_dateNotBefore_s title}

    if SOLR_URL
      $solr = RSolrCdrh::Query.new(SOLR_URL, fields)

      # Retrieve # of rows first so not relying on hard-coded limit
      rows = $solr.query({
        "q" => "lc_searchtype_s:journal_file",
        "fl" => "id",
        "rows" => 1,
      })[:num_found]

      res = $solr.query({
        "q" => "lc_searchtype_s:journal_file",
        "rows" => rows,
        "sort" => "lc_dateNotBefore_s asc",
      })

      return res[:docs]
    end
  end

  def make_calendar_json journals
    date_last_new = ""
    multi_entry_odd = false
    single_entry_odd = false

    js_obj = "dates = ["
    journals.each do |item|
      creators = item["creators"] ? item["creators"].join("; ") : "No creators"
      date1 = item["lc_dateNotBefore_s"]
      date2 = item["lc_dateNotAfter_s"]
      id = item["id"]
      title = item["title"]

      if date_last_new != date1
        date_last_new = date1
        single_entry_odd = !single_entry_odd
      end

      if date1 != date2
        multi_entry_odd = !multi_entry_odd

        color = (multi_entry_odd) ? "#FFA200" : "#F95319"
      else
        color = (single_entry_odd) ? "#305175" : "#65A2E5"
      end

      if !date1.blank? && !date2.blank?
        y1, m1, d1 = date1.split("-")
        y2, m2, d2 = date2.split("-")

        # javascript uses zero-indexed months
        m1 = m1.to_i - 1
        m2 = m2.to_i - 1

        item_data = <<-END.squish
          {
            color: "#{color}",
            id: "#{id}",
            location: "#{creators}",
            name: "#{title}",

            startDate: new Date(#{y1}, #{m1}, #{d1}),
            endDate: new Date(#{y2}, #{m2}, #{d2}),
          },
        END

        js_obj += item_data
      else
        puts "no date match for #{id}"
      end
    end
    js_obj += "];"

    return js_obj
  end

  def write_to_file date_info
    File.open(DATA_FILE, "w") do |file|
      file.write(date_info)
    end
  end

  task create: :environment do
    SOLR_URL = CONFIG['solr_url']

    puts "Retrieving journal entries from Solr (#{SOLR_URL})\n\n"
    journals = get_journals

    if journals.blank?
      puts "No journal entries returned from Solr"
      puts "Check the Solr index and try again\n\n"

      exit(1)
    end

    puts "Generating JSON\n\n"
    date_info = make_calendar_json journals

    puts "Writing to: #{DATA_FILE}\n\n"
    write_to_file date_info
  end

end

