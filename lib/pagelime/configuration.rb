require 'logger'

module Pagelime
  class Configuration
    
    # only allow getter access unless using configure block
    attr_accessor :account_key, :account_secret, :api_version, :client_class, :processor_class, :logger
    attr_reader :client, :processor
    
    # pass in a configure block to write new values
    def initialize(defaults = {}, &block)
      @account_key     = ENV['PAGELIME_ACCOUNT_KEY']
      @account_secret  = ENV['PAGELIME_ACCOUNT_SECRET']
      @api_version     = ENV['PAGELIME_RACK_API_VERSION']
      @logger          = Logger.new(STDOUT)
      
      configure(&block)
    end
    
    def configure(&block)
      if block_given?
        # pass self to configuration block
        yield(self)
        
        # recreate instances in case classes were updated
        rebuild!
      end
      
      self
    end
    
    def rebuild!
      if client_class.nil? || processor_class.nil?
        raise "You must specify client_class and processor_class"
      end
      
      @client     = client_class.new(account_key, account_secret, api_version)
      @processor  = processor_class.new(@client)
    end
  end
end