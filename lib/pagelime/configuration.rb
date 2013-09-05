module Pagelime
  class Configuration
    
    attr_accessor :account_key, :account_secret, :api_version
    attr_accessor :logger
    
    def initialize
      
      # client settings
      
      account_key     = ENV['PAGELIME_ACCOUNT_KEY']
      account_secret  = ENV['PAGELIME_ACCOUNT_SECRET']
      api_version     = ENV['PAGELIME_RACK_API_VERSION']
      
      # global settings
      
      logger          = self.class.default_logger
    end
    
    module ClassMethods
      def default_logger
        @default_logger ||= Logger.new(STDOUT)
      end
    end
    
    extend ClassMethods
    
  end
end