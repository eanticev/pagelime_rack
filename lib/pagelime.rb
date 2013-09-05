require_relative 'pagelime/configuration'

module Pagelime
  module ClassMethods
    # Use as Pagelime.configure{|config| config.account_key = ... }
    def configure(&block)
      config.configure(&block)
    end
    
    def config
      @config ||= Configuration.new
    end
    
    def logger
      config.logger
    end
    
    def client
      config.client
    end
    
    def processor
      config.processor
    end
  end
  
  extend ClassMethods
end
