require "nokogiri"
require "base64"
require "net/http"

require_relative 'pagelime/configuration'

module Pagelime
  module ClassMethods
    def config
      @config ||= Configuration.new
    end
    
    # Use as Pagelime.configure{|config| config.account_key = ... }
    def configure(&block)
      yield config
    end
  end
  
  extend ClassMethods
  
  def cms_api_signature(req)
    secret    = ::Pagelime.config.account_secret
    signature = Base64.encode64(OpenSSL::HMAC.digest('sha1', secret, req).to_s)
    return signature
  end
  
  def fetch_cms_shared_xml
  
    # TODO: check cache (see the rails plugin for info)
  
    if (@opts[:log] == "verbose") 
      puts "PAGELIME CMS PLUGIN: NO SHARED CACHE... loading xml"
    end
  
    # set input values
    key = ::Pagelime.config.account_key
    
    # get the url that we need to post to
    http = Net::HTTP::new('s3.amazonaws.com',80)
    
    # send the request
    response = http.get("/cms_assets/heroku/#{key}/shared-regions.xml")
    
    # puts "PAGELIME CMS PLUGIN: response XML: #{response.body}"
    
    xml_content = response.body
    
    return xml_content
    
  end
  
  def fetch_cms_xml(page_path, element_ids)
  
    page_key = Base64.encode64(page_path)
  
    # TODO: check cache (see the rails plugin for info)
  
    if (@opts[:log] == "verbose") 
      puts "PAGELIME CMS PLUGIN: NO '#{page_path}' CACHE... loading xml"
    end
    
    # set input values
    key = ::Pagelime.config.account_key
    
    # get the url that we need to post to
    http = Net::HTTP::new('s3.amazonaws.com',80)
    
    response = http.get("/cms_assets/heroku/#{key}/pages#{page_path}.xml")
    
    xml_content = response.body
    
    return xml_content
    
  end
  
  def cms_process_html_block_regions(editable_regions, xml_content)
  
    editable_regions.each do |div| 
    
      # Grab client ID
      client_id = div["id"]
      
      if (@opts[:log] == "verbose") 
        puts "PAGELIME CMS PLUGIN: parsing xml"
      end
  
      soap = Nokogiri::XML::Document.parse(xml_content)
      
      if (@opts[:log] == "verbose") 
        puts "PAGELIME CMS PLUGIN: looking for region: #{client_id}"
      end
  
      xpathNodes = soap.css("EditableRegion[@ElementID=\"#{client_id}\"]")
      
      if (@opts[:log] == "verbose") 
        puts "regions found: #{xpathNodes.count}"
      end
  
      if (xpathNodes.count > 0)
        new_content = xpathNodes[0].css("Html")[0].content()
        
        if (@opts[:log] == "verbose") 
          puts "PAGELIME CMS PLUGIN: NEW CONTENT:"
          puts new_content
        end
        
        if (new_content)
          # div.content = "Replaced content"
          div.replace new_content
        end
      end
    
    end

  end
  
  # options = { :page_path => nil, :html => "", :fragment => true }
  def cms_process_html_block(options = {})
    
    options = { :page_path => nil, :html => "", :fragment => true }.merge(options)
    
    page_path = options[:page_path]
    html      = options[:html]
    fragment  = options[:fragment]

    unless ::Pagelime.config.configured?
      puts "PAGELIME CMS PLUGIN: Environment variables not configured"
      return html
    end
  
    # use nokogiri to replace contents
    doc = fragment ? Nokogiri::HTML::DocumentFragment.parse(html) : Nokogiri::HTML::Document.parse(html) 
    editable_regions = doc.css(".cms-editable")
    shared_regions = doc.css(".cms-shared")
    
    region_client_ids = Array.new
      
    editable_regions.each do |div| 
    region_client_ids.push div["id"]
    end
    
    cms_process_html_block_regions(editable_regions, fetch_cms_xml(page_path,region_client_ids))
    cms_process_html_block_regions(shared_regions,fetch_cms_shared_xml())
      
    return doc.to_html
    
  end
end
