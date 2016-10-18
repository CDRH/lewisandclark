class StaticController < ApplicationController
  def index
    @page_type = "home"
  end
  
  def about
    @page_type = "about"
  end
end
