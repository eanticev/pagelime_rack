require 'base64'

module Pagelime
  class CacheEngine
    
    def initialize(config)
      @config = config
    end
    
    ### CMS-specific methods
    
    def fetch_path(page_path, &block)
      cache_key = generate_region_cache_key(page_path)
      
      fetch(cache_key, fetch_options, &block)
    end
    
    def fetch_shared(&block)
      cache_key = static_shared_cache_key
      
      fetch(cache_key, fetch_options, &block)
    end
    
    def fetch_include(include_id,&block)
      cache_key = generate_include_cache_key(include_id)
      
      fetch(cache_key, fetch_options, &block)
    end
    
    def clear_page(page_path)
      cache_key = generate_region_cache_key(page_path)
      
      delete cache_key
    end
    
    def clear_shared
      cache_key = static_shared_cache_key
      
      delete cache_key
    end
    
    ### Generic cache methods
    
    def fetch(key, options = {}, &block)
      if @config.cache
        @config.cache.fetch(key, fetch_options, &block)
      else
        yield
      end
    end
    
    def delete(key)
      @config.cache.delete(key) if @config.cache
    end
    
    private
    
    def generate_region_cache_key(page_path)
      if @config.generate_region_cache_key.respond_to? :call
        @config.generate_region_cache_key.call(page_path)
      else
        "pagelime:cms:page:#{Base64.encode64(page_path)}"
      end
    end
    
    def generate_include_cache_key(include_id)
      if @config.generate_include_cache_key.respond_to? :call
        @config.generate_include_cache_key.call(include_id)
      else
        "pagelime:cms:include:#{Base64.encode64(include_id)}"
      end
    end
    
    def static_shared_cache_key
      @config.static_shared_cache_key || "pagelime:cms:shared"
    end
    
    def fetch_options
      @config.cache_fetch_options || {}
    end
  end
end