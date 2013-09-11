require 'logger'

module Pagelime
  class Configuration
    
    # only allow getter access unless using configure block
    attr_accessor :logger, :storage, :cache, :processor
    attr_accessor :generate_region_cache_key, :static_shared_cache_key, :cache_fetch_options
    
    # pass in a configure block to write new values
    def initialize(defaults = {}, &block)
      @logger = Logger.new(STDOUT)
      
      configure(&block)
    end
    
    def configure(&block)
      yield(self) if block_given?
      
      self
    end
  end
end