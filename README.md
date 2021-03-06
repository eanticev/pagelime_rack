Pagelime Rack Plugin
=====================

Easily add the Pagelime CMS to your Rack app.

Pagelime is a simple CMS service that allows you to define editable regions in your pages without installing any software on your website or app. 
Simply add a `class="cms-editable"` to any HTML element, and log-in to the Pagelime CMS service to edit your content and images with a nice, simple UI. 
We host all of the code, content, and data until you publish a page. 
When you publish a page, the PageLime CMS pushes the content to your website via secure FTP or an API. 
Using the Rack middleware, we pull the new content into your app dynamically via an API.

### Quick Start (1 line of code!)

Simply add the `cms-editable` class and an `id` to make content editable:

```html
<div id="my_content" class="cms-editable">
  This content is now editable in Pagelime... no code... no databases... no fuss
</div>
```

Done!

Getting Started
---------------

### Requirements

* Pagelime account (either standalone [pagelime.com](http://pagelime.com) or via the [Pagelime Heroku add-on](https://addons.heroku.com/pagelime))
* Nokogiri gem

### Step 1: Install the Pagelime Rack gem

Edit your `Gemfile` and add

```ruby
gem "pagelime-rack"
```

then run

```Bash
bundle install
```

### Step 2: Setup your Pagelime credentials

*(Skip if using Heroku add-on)*

If you are NOT using the [Pagelime Heroku add-on](https://addons.heroku.com/pagelime), set up an account at [pagelime.com](http://pagelime.com). 
Make sure that the "Integration Method" for your site on the advanced tab is set to "web services".

### Step 3: Configure your application

Set up your Environment variables: *(Skip if using Heroku add-on)*

```ruby
ENV['PAGELIME_ACCOUNT_KEY']      = "..."
ENV['PAGELIME_ACCOUNT_SECRET']   = "..."
ENV['PAGELIME_RACK_API_VERSION'] = "1.0"
```

Optionally, enable caching:

```ruby
Pagelime.configure do |config|

  # object that responds to `fetch` and `delete`
  config.cache = ...
  
  # options passed to `fetch(key, options = {}, &block)`
  config.cache_fetch_options = { ... }
  
end
```

### Step 4: Make pages editable

Create some editable regions in your views like so:

```html
<div id="my_content" class="cms-editable">
  this is now editable
</div>
```

*The `ID` and the `class` are required for the CMS to work*

### Step 5: Edit your pages!

#### For Heroku users

If you're using the Pagelime Heroku add-on, go to the Heroku admin for your app and under the "Resources" tab you will see the Pagelime add-on listed. 
Click on the add-on name and you will be redirected to the Pagelime CMS editor. 
From there you can edit any page in your Rack app!

#### For Pagelime.com users

If you have a standalone Pagelime account, simply go to [pagelime.com](http://pagelime.com) and edit your site as usual (see Step 2). 

Sinatra Sample
--------------

```ruby
# Set the environment variables BEFORE requiring the pagelime-rack gem

ENV['PAGELIME_ACCOUNT_KEY']      = "..."
ENV['PAGELIME_ACCOUNT_SECRET']   = "..."
ENV['PAGELIME_RACK_API_VERSION'] = "1.0"

# Setup Sinatra app

require 'sinatra'
require 'pagelime-rack'

use Rack::Pagelime

get '/page/about' do
  content_type "text/html"
  return '<div id="content" class="cms-editable">Hello World!</div>'
end
```

Copyright (c) 2013 Pagelime LLC, released under the MIT license

