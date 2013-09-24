require 'rack'
require 'rack/lobster'
require './lib/rack/pagelime'

use Rack::Pagelime

Pagelime.configure do |config|
  config.toggle_processing = "per_request"
  config.url_path = "bogus"
end

run Rack::Lobster.new#lambda{|env| [200, {}, [':-(']] }
