require "base64"
require "net/http"

module Pagelime
  module Clients
    class XmlS3Storage
      
      def initialize(options = {})
        @options = {
          :account_key    => ENV['PAGELIME_ACCOUNT_KEY'],
          :account_secret => ENV['PAGELIME_ACCOUNT_SECRET'],
          :api_version    => ENV['PAGELIME_RACK_API_VERSION']
        }.merge(options)
      end
      
      def fetch_shared
      
        Pagelime.logger.debug "PAGELIME CMS RACK PLUGIN: NO SHARED CACHE... loading XML"
        
        content = request_content("/cms_assets/heroku/#{@options[:account_key]}/shared-regions.xml")
        
        Pagelime.logger.debug "PAGELIME CMS RACK PLUGIN: Shared content: #{content.inspect}"
        
        content
      end
      
      def fetch_path(page_path)
        
        Pagelime.logger.debug "PAGELIME CMS RACK PLUGIN: NO '#{page_path}' CACHE... loading XML"
        
        content = request_content("/cms_assets/heroku/#{@options[:account_key]}/pages#{page_path}.xml")
        
        Pagelime.logger.debug "PAGELIME CMS RACK PLUGIN: Content: #{content.inspect}"
        
        content
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
end