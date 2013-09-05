require "base64"
require "net/http"

module Pagelime
  class S3Client
    
    attr_reader :account_key, :account_secret, :api_version
    attr_reader :default_format
    
    def initialize(account_key, account_secret, api_version)
      # reference config object to ensure we have the latest credentials, etc
      @account_key    = account_key
      @account_secret = account_secret
      @api_version    = api_version
      @default_format = :xml
      
      #raise "WARNING: Account key, secret, and API version were not specified!" unless configured?
    end
    
    def configured?
      !(account_key.nil? || account_secret.nil? || api_version.nil?)
    end
    
    # def cms_api_signature(req)
      # secret    = account_secret
      # signature = Base64.encode64(OpenSSL::HMAC.digest('sha1', secret, req).to_s)
      # return signature
    # end
    
    def fetch_shared(format = default_format)
    
      # TODO: check cache (see the rails plugin for info)
    
      ::Pagelime.logger.debug "PAGELIME CMS PLUGIN: NO SHARED CACHE... loading #{format}"
      
      content = request_content("/cms_assets/heroku/#{account_key}/shared-regions.#{format}")
      
      # puts "PAGELIME CMS PLUGIN: response XML: #{xml_content}"
      
      content
    end
    
    def fetch(page_path, format = default_format)
      
      # TODO: Should element_ids be used anywhere?
      
      # TODO: Should page_key be used anywhere?
      page_key = Base64.encode64(page_path)
    
      # TODO: check cache (see the rails plugin for info)
    
      Pagelime.logger.debug "PAGELIME CMS PLUGIN: NO '#{page_path}' CACHE... loading #{format}"
      
      content = request_content("/cms_assets/heroku/#{account_key}/pages#{page_path}.#{format}")
      
      content
    end
    
    private
    
    def request_content(url)
      http.get(url).body
    end
    
    def http
      @http ||= Net::HTTP::new('s3.amazonaws.com', 80)
    end
    
  end
end