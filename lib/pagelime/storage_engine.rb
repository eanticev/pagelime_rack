module Pagelime
  class StorageEngine
    
    attr_reader :cache
    
    def initialize(config, cache_engine)
      @config = config
      @cache  = cache_engine# || CacheEngine.new(config)
    end
    
    def fetch_path(page_path)
      @cache.fetch_path page_path do
        @config.storage.fetch_path(page_path)
      end
    end
    
    def fetch_shared
      @cache.fetch_shared do
        @config.storage.fetch_shared
      end
    end
  end
end