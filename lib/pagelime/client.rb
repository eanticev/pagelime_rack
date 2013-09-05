require "base64"
require "net/http"

module Pagelime
  class Client
    
    attr_accessor :config
    
    def initialize(config)
      # reference config object to ensure we have the latest credentials, etc
      @config = config
    end
    
    def configured?
      !(config.account_key.nil? || config.account_secret.nil? || config.api_version.nil?)
    end
    
    # def cms_api_signature(req)
      # secret    = ::Pagelime.config.account_secret
      # signature = Base64.encode64(OpenSSL::HMAC.digest('sha1', secret, req).to_s)
      # return signature
    # end
    
    def fetch_cms_shared_xml
    
      # TODO: check cache (see the rails plugin for info)
    
      ::Pagelime.logger.debug "PAGELIME CMS PLUGIN: NO SHARED CACHE... loading xml"
      
      # get the url that we need to post to
      http        = Net::HTTP::new('s3.amazonaws.com', 80)
      response    = http.get("/cms_assets/heroku/#{config.account_key}/shared-regions.xml")
      xml_content = response.body
      
      # puts "PAGELIME CMS PLUGIN: response XML: #{xml_content}"
      
      xml_content
    end
    
    def fetch_cms_xml(page_path, element_ids)
      
      # TODO: Should element_ids be used anywhere?
      
      # TODO: Should page_key be used anywhere?
      page_key = Base64.encode64(page_path)
    
      # TODO: check cache (see the rails plugin for info)
    
      ::Pagelime.logger.debug "PAGELIME CMS PLUGIN: NO '#{page_path}' CACHE... loading xml"
      
      # get the url that we need to post to
      http        = Net::HTTP::new('s3.amazonaws.com', 80)
      response    = http.get("/cms_assets/heroku/#{config.account_key}/pages#{page_path}.xml")
      xml_content = response.body
      
      xml_content
    end
    
  end
end