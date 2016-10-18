API Template for CDRH Solr Sites
=================

This website template is intended to be used with a solr core using the CDRH's [API schema](https://github.com/CDRH/data/blob/master/schema.md).  It should work out of the box with a home page, about page, simple browse, basic search (with pagination / faceting / sorting), and an item-level page.  There is some tweaking that you may wish to do in order to see certain fields and style the website.  Follow the instructions below to install and customize the site.

Install and Run Locally
-------------

First, you will need to get Ruby and Rails.  If you aren't running any other Ruby projects on your computer, then just go ahead and [install Rails](http://installrails.com/).  If you are using other Ruby projects, then it would be better to use a version manager like [RVM](https://rvm.io/rvm/install) or [rbenv](https://github.com/sstephenson/rbenv#installation) to avoid gem version conflicts between projects.  Make sure that you install the version of Ruby requested in `.ruby-version` to your version manager or straight to your machine, depending on which route you decided to take to get Rails.

You will also need to have `git` installed.  Create a new repository (without any files) on github or whatever host you prefer with the name of your new project.  Clone the template repository and change its remote to your new repository.

```
git clone git@github.com:CDRH/api_template.git your_project_name
git remote set-url origin git@github.com:USERNAME/OTHERREPOSITORY.git
```

Alrighty!  Now we just need to add some files to get this working.

```
cd your_project_name
cp config/database.example.yml config/database.yml
cp config/secrets.example.yml config/secrets.yml
cp config/solr.example.yml config/solr.yml
```

Run `rake secret`, copy the output, then past it into `config/secrets.yml` after the "development" line.  Now, open `config/solr.yml` and put in the path to your solr core.  It should look something like this:

```
development:
  solr_url: http://server.unl.edu:port/solr/solr_core
```

You may also want to change the name of the application in `config/application.rb` away from ApiTemplate to your new project's name.  This might be a good time to change the name in `.ruby-gemset` if you are using a ruby version manager like rvm.  If not, don't worry about the gemset. You'll also want to make sure that you change your session name.

```
# config/application.rb
module ApiTemplate
  class Application < Rails::Application
    #
  end
end

# config/initializers/session_store.rb
Rails.application.config.session_store :cookie_store, key: '_api_template_session'
```

Now the tricky part.  We need to install the gems that Rails needs to run.  It's very likely that you don't have "bundler" yet, so we'll need to install this first.  __Don't run any of the following as sudo on a server__.  On your local machine it will still probably cause problems, but at least it's just your own computer.

```
gem install bundler
bundle install
```

It may take a few minutes to download all the gems.  Assuming that all went well, try starting it up:

```
rails s
```

You should be able to navigate to localhost:3000 in a browser and see a beautiful little site with some basic searching and browsing of your solr core.  Now, onto the customization!


Customization Searching
--------------

In `app/controllers/application_controller.rb` there are some defaults specified for the solr queries your application is sending.  These will override the defaults set by the rsolr_cdrh gem that the application is using ([see those defaults here](https://github.com/CDRH/rsolr_cdrh/blob/master/lib/rsolr_cdrh/rsolr_cdrh.rb#L12)).  

```
$solr.set_default_query_params({
  :sort => "score desc",
  :hl => "true",
  :rows => 50
  })
$solr.set_default_facet_params({
  "facet.limit" => "-1",
  "facet.mincount" => "1",
  "facet.sort" => "count"
  # "facet.sort" => "index"
  })
```

For example, if you have a dataset with both people and documents, but you want to search only for documents most of the time, you might add something like this:

```
:fq => "category:documents"
# that is equivalent to the following line
:fqfield => "category",
:fqtext => "documents"
```

This is a good time to change the default facets, too.  Rather than doing that through the $solr object, because facets are used all over the place, open up `app/models/facets.rb`.  Go ahead and modify the list to match __single valued__ solr fields.  I'm working on the multivalued one for the future, but just trust me for now that you don't want to go there yet.

```
module Facets
  def self.facet_list
    return [
      "creator",
      "source",
      "category",
      "subCategory"
    ]
  end
end
```

When an individual document is displayed, some metadata appears at the top and a pre-generated HTML snippet is grabbed, assuming that the solrification of your TEI went well.  You can change the metadata showing up at the top in `app/views/documents/show.html.erb`.  The "metadata" method makes a very basic list of links to a search page.  You may want to comment them out or rewrite the "metadata" method in `app/helpers/document_helper.rb` if you don't like that behavior.

```
# displays the document title, if it exists, and does not link (false as final param)
<%= metadata("Title", "title", @doc["title"], false) %>
# display the date, if it exists, and it will generate a link
<%= metadata("Date", "dateDisplay", @doc["dateDisplay"]) %>
```

You will need to restart the rails server in order to see changes that you make to the solr default parameters.  `Ctrl+C` then `rails s` to restart.

Customize Appearance
-----------------

You'll also probably want to make your own header and footer.  Open up `app/views/layouts/application.html.erb`.  If you are familiar with HTML then it should look pretty straightforward.  If not, here is what you are going to want to change:

```
<title>Site Title</title>
<!-- .... -->
<script type="text/javascript">
  // Google analytics
</script>
<!-- .... -->
<h1>Title of Project</h1>
<h2>Subtitle for CDRH Rails Solr API Site</h2>
```

Whatever you do, make sure that you don't add any CSS or JavaScript in the header unless if they are external resources (like to a CDN).  We'll get to adding JS and CSS later!

You may also want to change the favicon to something besides a lovely rainbow.  If so, just drop a new `favicon.ico` file in at `app/assets/images/favicon.ico`.

On to the home page!  There is some text that is already there acting as a placeholder which exists in `app/views/static/index.html.erb`.  While you're in `app/views/static`, you might also want to take a look at `app/views/static/about.html.erb` to craft an "about" page for your project.  Here are some things you may wish to add while you are on one of those pages:

```
# image
<%= image_tag 'image.jpg', class: "image_class", alt: "Super image" %>

# link to interior page (home)
<%= link_to "Home", home_path %>

# link to interior page with image
<%= link_to "Home", home_path do %>
  <%= image_tag 'image.jpg' %>
<% end %>

# link to interior page for search results
<%= link_to "'Water' results", search_path({:qfield => "text", :qtext => "water"}) %>

# link to exterior page
<a href="http://normal/link.com">Exterior sites can just have normal links</a>
```

Styling, Scripts, and Images
----------------

Okay.  So you want to add some styling?  Generally, external CSS should be added in the `vendor` directory but since we're altering bootstrap, it exists in `app/assets/stylesheets`.  Checkout `app/assets/stylesheets/bootstrap/_variables.scss` to change some of the site's colors and settings about buttons, divs, etc.  There is also a stylesheet at `app/assets/stylesheets/style.scss` that has some further modifications you might like to use.  This is another non-traditional rails thing, but if you would like to add a new stylesheet, you will need to add that to `app/assets/stylesheets/application.css`:

```
 *= require style
 *= require new_stylesheet
```

To add (non-jquery) JavaScript, simply add the file(s) to `app/assets/javascripts` and they should be automatically included.  jQuery should already be loaded up and ready to go (cross your fingers) so hopefully you don't need to mess with that.

Note:  For the developers reading this, you'll probably want to know that turbolinks is turned off.  To turn it on, you'll need to uncomment a few lines in `application.js` as well as the turbolinks and turbolinks jquery gems in the Gemfile.  Good luck with your poor choice, enjoy debugging impossible situations.  Actually, I exaggerate, turbolinks should work fine with this site except for the @page_type variable setting a class at the top of pages.

Images are the most straightforward of all!  Just drag files into `app/assets/images` and include them with their name in CSS and in the views.

```
# display an image at app/assets/images/nebraska.png
<%= image_tag "nebraska.png" %>

# display an image at app/assets/images/authors/whitman.jpg
<%= image_tag "authors/whitman.jpg" %>
```

Add New Pages
----------------

I would recommend that you get a developer to do this part if your page is going to be complicated, but as long as you are only adding static pages, it should be pretty straightforward to add some pages.  Let's add a "Technical Info" page as a subpage of "About."  Open up `config/routes.rb`.

```
# this line is already in routes.rb
get 'about' => 'static#about', as: :about

# add a new route with following format
# HTTP method 'url/path' => 'controller#action', as: :name_of_route
get 'about/info' => 'static#info', as: :about_info
```

If you need to set any variables, add a new action to the specified controller, which should be in `app/controllers`.  Otherwise, skip the action and make a new file in the appropriate place in `app/views`.  For example, if your route says `static#info` you will need to put a file called `info.html.erb` in `app/views/static`.

Put the Project on a Server
-----------------

You will need [Phusion Passenger](https://www.phusionpassenger.com/) installed if you want to run Rails with an Apache server.  Git clone your repository (should be your newly created one, NOT this one) into a non-web tree directory.  __If you put the repo in the web tree, the security of your site may be compromised!__

To make a development alias, add the following to your Apache configuration.  The below also assumes that you are using RVM as a version manager, otherwise you should simply be able to omit "PassengerRuby" from the configuration.

```
Alias /api_rails_template "/var/www/rails/api_rails_template/public"
# Tell passenger where it should be operating
<Location /api_rails_template>
  PassengerBaseURI /api_rails_template
  PassengerAppRoot /var/www/rails/api_rails_template
  RailsEnv development
  PassengerRuby /usr/local/rvm/gems/ruby-2.2.0-preview1@api_template/wrappers/ruby
</Location>
<Directory /var/www/rails/api_rails_template/public>
  Options -MultiViews -Indexes
  AllowOverride all
  Order allow,deny
  Allow from all
  Require all granted
  # ErrorLog /etc/httpd/logs/api_template_errors
</Directory>
```


TODO write this section

- Change to production
- Precompile assets
- secrets.yml env
- Put into phusion passenger / apache
- switch config to production solr core
