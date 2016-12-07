class StaticController < ApplicationController
  def index
    @page_type = "home"
  end

  def about
    @page_type = "about"
  end

  def browserconfig
    render layout: false, content_type: "text/xml"
  end
end

