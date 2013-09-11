require_relative 'pagelime/configuration'
require_relative 'pagelime/storage_engine'
require_relative 'pagelime/cache_engine'

module Pagelime
  module ClassMethods
    # Use as Pagelime.configure{|config| config.account_key = ... }
    def configure(&block)
      config.configure(&block)
    end
    
    def process_page(html, page_path)
      config.processor.process_document(storage, html, page_path)
    end
    
    def process_region(html, page_path)
      config.processor.process_fragment(storage, html, page_path)
    end
    
    def storage
      @storage ||= StorageEngine.new(config, cache)
    end
    
    def cache
      @cache ||= CacheEngine.new(config)
    end
    
    def config
      @config ||= Configuration.new
    end
    
    def logger
      config.logger
    end
  end
  
  extend ClassMethods
end
