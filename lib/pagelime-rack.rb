require_relative 'pagelime'
require_relative 'pagelime/clients/xml_s3_storage'
require_relative 'pagelime/clients/xml_processor'
require_relative 'rack/pagelime'

Pagelime.configure do |config|
  #config.cache = ...
  config.storage    = Pagelime::Clients::XmlS3Storage.new
  config.processor  = Pagelime::Clients::XmlProcessor.new
end
