require_relative 'pagelime/configuration'
require_relative 'pagelime/client'
require_relative 'pagelime/html_processor'

module Pagelime
  module ClassMethods
    # Use as Pagelime.configure{|config| config.account_key = ... }
    def configure(&block)
      yield config
    end
    
    def config
      @config ||= Configuration.new
    end
    
    def logger
      config.logger ||= Configuration.default_logger
    end
    
    def client
      @client ||= Client.new(config)
    end
    
    def html_processor
      @html_processor ||= HtmlProcessor.new(client)
    end
  end
  
  extend ClassMethods
end
