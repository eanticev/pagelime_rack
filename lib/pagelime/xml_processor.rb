require "nokogiri"

module Pagelime
  class XmlProcessor
    
    attr_reader :client
    attr_reader :format
    
    def initialize(client)
      @client = client
      @format = :xml
    end
    
    def process_document(html, page_path = false)
      doc = Nokogiri::HTML::Document.parse(html)
      
      # return original HTML if nil returned
      parse_document(doc, page_path) || html
    end
    
    def process_fragment(html, page_path = false)
      doc = Nokogiri::HTML::DocumentFragment.parse(html)
      
      # return original HTML if nil returned
      parse_document(doc, page_path) || html
    end
    
    private
    
    # options = { :page_path => nil, :html => "", :fragment => true }
    def parse_document(doc, page_path = false)
      
      unless client.configured?
        ::Pagelime.logger.warn "PAGELIME CMS PLUGIN: Environment variables not configured"
        return nil
      end
    
      # use nokogiri to replace contents
      editable_regions  = doc.css(".cms-editable")
      shared_regions    = doc.css(".cms-shared")
      
      patch_regions editable_regions, client.fetch(page_path, format)
      patch_regions shared_regions, client.fetch_shared(format)
        
      return doc.to_html
      
    end
    
    def patch_regions(editable_regions, xml_content)
    
      ::Pagelime.logger.debug "PAGELIME CMS PLUGIN: parsing xml"
    
      editable_regions.each do |div| 
      
        # Grab client ID
        client_id = div["id"]
        soap      = Nokogiri::XML::Document.parse(xml_content)
        nodes     = soap.css("EditableRegion[@ElementID=\"#{client_id}\"]")
        
        ::Pagelime.logger.debug "PAGELIME CMS PLUGIN: looking for region: #{client_id}"
        ::Pagelime.logger.debug "regions found: #{nodes.count}"
    
        if nodes.any?
          new_content = nodes[0].css("Html")[0].content
          
          ::Pagelime.logger.debug "PAGELIME CMS PLUGIN: NEW CONTENT:"
          ::Pagelime.logger.debug new_content
          
          if new_content
            # div.content = "Replaced content"
            div.replace new_content
          end
        end
      
      end
  
    end
    
  end
end