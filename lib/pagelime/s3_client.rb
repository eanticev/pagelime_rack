require "base64"
require "net/http"

module Pagelime
  class S3Client
    
    module ClassMethods
      def default_format
        :xml
      end
    end
    
    extend ClassMethods
    
    attr_reader :account_key, :account_secret, :api_version
    
    def initialize(account_key, account_secret, api_version)
      # reference config object to ensure we have the latest credentials, etc
      @account_key    = account_key
      @account_secret = account_secret
      @api_version    = api_version
      
      #raise "WARNING: Account key, secret, and API version were not specified!" unless configured?
    end
    
    def configured?
      !(account_key.nil?)# || account_secret.nil? || api_version.nil?)
    end
    
    # def cms_api_signature(req)
      # secret    = account_secret
      # signature = Base64.encode64(OpenSSL::HMAC.digest('sha1', secret, req).to_s)
      # return signature
    # end
    
    def fetch_shared(format = self.class.default_format)
    
      # TODO: check cache (see the rails plugin for info)
    
      ::Pagelime.logger.debug "PAGELIME CMS RACK PLUGIN: NO SHARED CACHE... loading #{format}"
      
      content = request_content("/cms_assets/heroku/#{account_key}/shared-regions.#{format}")
      
      # ::Pagelime.logger.debug "PAGELIME CMS RACK PLUGIN: shared XML: #{content}"
      
      Pagelime.logger.debug "PAGELIME CMS RACK PLUGIN: Shared content: #{content.inspect}"
      
      content
    end
    
    def fetch(page_path, format = self.class.default_format)
      
      # TODO: Should element_ids be used anywhere?
      
      # TODO: Should page_key be used anywhere?
      page_key = Base64.encode64(page_path)
    
      # TODO: check cache (see the rails plugin for info)
    
      Pagelime.logger.debug "PAGELIME CMS RACK PLUGIN: NO '#{page_path}' CACHE... loading #{format}"
      
      content = request_content("/cms_assets/heroku/#{account_key}/pages#{page_path}.#{format}")
      
      Pagelime.logger.debug "PAGELIME CMS RACK PLUGIN: Content: #{content.inspect}"
      
      content
    end
    
    def clear(page_path, format = self.class.default_format)
      Pagelime.logger.warn "PAGELIME CMS RACK PLUGIN: #{self.class.name}##{__method__} is not implemented!"
    end
    
    def clear_shared(format = self.class.default_format)
      Pagelime.logger.warn "PAGELIME CMS RACK PLUGIN: #{self.class.name}##{__method__} is not implemented!"
    end
    
    private
    
    def request_content(url)
      response = http.get(url)
      
      Pagelime.logger.debug "PAGELIME CMS RACK PLUGIN: S3 response code: #{response.code.inspect}"
      
      # only return the body if response code 200-399
      response.body if (200...400).include?(response.code.to_f)
    end
    
    def http
      @http ||= Net::HTTP::new('s3.amazonaws.com', 80)
    end
    
  end
end