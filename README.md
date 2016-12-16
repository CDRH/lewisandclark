Journals of the Lewis and Clark Expedition
=================

This rails project powers the [https://lewisandclarkjournals.unl.edu/](Journals of the Lewis and Clark Expedition) website.  It is intended for use with a Solr index designed around the CDRH's [API schema](https://github.com/CDRH/data/blob/master/schema.md)

## Technology

ruby 2.3.1
rails 5.0.0.1
solr 5.5.0
TEI P5

For more information, please see the [https://lewisandclarkjournals.unl.edu/item/lc.about.technicalsummary](Technical Summary).

## Installation

If you are looking to run this app locally, you will need to copy and configure the examples of the following files:  `config/solr.yml`, `config/secrets.yml`, `config/database.yml`.  You will also need to create a Solr core with the API fields.  This site has no relational database attached to it.  Add fields you would like to facet over to `app/models/facets.rb`

## Generate Calendar Dates

If you wish to make changes to the calendar, you can run a rake task to update the `dates.js` file using solr results.

`rake calendar:create`

## Attribution and Project Team

More information is available on the [https://lewisandclarkjournals.unl.edu/about](about pages).
