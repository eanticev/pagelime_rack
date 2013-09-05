require_relative 'pagelime'
require_relative 'pagelime/s3_client'
require_relative 'pagelime/xml_processor'
require_relative 'rack/pagelime'

Pagelime.configure do |config|
  config.client_class     = Pagelime::S3Client
  config.processor_class  = Pagelime::XmlProcessor
end
