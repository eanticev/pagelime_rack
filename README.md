Pagelime Rack Plugin
=====================

Easily add the Pagelime CMS to your rack app.

Pagelime is a simple CMS service that allows you to define editable regions in your content without installing any software on your site or app. 
Simply add a `class="cms-editable"` to any HTML element, and log-in to the Pagelime CMS service to edit your content and images with a nice UI. 
We host all of the code, content, and data until you publish a page. 
When you publish a page, we push the content to your site/app via secure FTP or web APIs.

One line example:

    <div id="my_content" class="cms-editable">
      This content is now editable in Pagelime... no code... no databases... no fuss
    </div>

Getting Started
---------------

### Requirements

* Pagelime account (either a standalone from pagelime.com or as a Heroku add-on)
* Nokogiri gem

### Step 1: Install the Pagelime gem

Edit your `Gemfile` and add

    gem "pagelime-rack"

then run

    bundle install

### Step 2: Configure your application

Set up your Environment variables:

    ENV['PAGELIME_ACCOUNT_KEY'] = "..."
    ENV['PAGELIME_ACCOUNT_SECRET'] = "..."
    ENV['PAGELIME_RACK_API_VERSION'] = "1.0"

*Skip if using Heroku add-on*

Alternatively, configure them explicitly:

    Pagelime.configure do |config|
      config.account_key = "..."
      config.account_secret = "..."
      config.api_version = "1.0"
    end

### Step 3: Make pages editable

Create some editable regions in your views like so:

    <div id="my_content" class="cms-editable">
      this is now editable
    </div>

*The ID and the class are required for the CMS to work*

Sinatra Sample
--------------

    require 'sinatra'
    require 'pagelime-rack'
    
    configure :development do
      ENV['PAGELIME_ACCOUNT_KEY'] = "..."
      ENV['PAGELIME_ACCOUNT_SECRET'] = "..."
      ENV['PAGELIME_RACK_API_VERSION'] = "1.0"
    end
    
    use Rack::Pagelime
    
    get '/page/about' do
      content_type "text/html"
      return "<div id=\"content\" class=\"cms-editable\">Hello World!</div>"
    end

Copyright (c) 2013 Pagelime LLC, released under the MIT license
