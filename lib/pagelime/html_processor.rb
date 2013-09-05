require "nokogiri"

module Pagelime
  class HtmlProcessor
    
    attr_reader :client
    
    def initialize(client)
      @client = client
    end
    
    def process_document(html, page_path = false)
      doc = Nokogiri::HTML::Document.parse(html)
      
      cms_process_html_block(doc, page_path)
    end
    
    def process_fragment(html, page_path = false)
      doc = Nokogiri::HTML::DocumentFragment.parse(html)
      
      cms_process_html_block(doc, page_path)
    end
    
    # options = { :page_path => nil, :html => "", :fragment => true }
    def cms_process_html_block(doc, page_path = false)
      
      unless client.configured?
        puts "PAGELIME CMS PLUGIN: Environment variables not configured"
        return html
      end
    
      # use nokogiri to replace contents
      editable_regions  = doc.css(".cms-editable")
      shared_regions    = doc.css(".cms-shared")
      region_client_ids = editable_regions.map{|div| div["id"]}
      
      cms_process_html_block_regions editable_regions, client.fetch_cms_xml(page_path, region_client_ids)
      cms_process_html_block_regions shared_regions, client.fetch_cms_shared_xml
        
      return doc.to_html
      
    end
    
    def cms_process_html_block_regions(editable_regions, xml_content)
    
      editable_regions.each do |div| 
      
        # Grab client ID
        client_id = div["id"]
        
        ::Pagelime.logger.debug "PAGELIME CMS PLUGIN: parsing xml"
    
        soap = Nokogiri::XML::Document.parse(xml_content)
        
        ::Pagelime.logger.debug "PAGELIME CMS PLUGIN: looking for region: #{client_id}"
    
        xpathNodes = soap.css("EditableRegion[@ElementID=\"#{client_id}\"]")
        
        ::Pagelime.logger.debug "regions found: #{xpathNodes.count}"
    
        if (xpathNodes.count > 0)
          new_content = xpathNodes[0].css("Html")[0].content()
          
          ::Pagelime.logger.debug "PAGELIME CMS PLUGIN: NEW CONTENT:"
          ::Pagelime.logger.debug new_content
          
          if (new_content)
            # div.content = "Replaced content"
            div.replace new_content
          end
        end
      
      end
  
    end
    
  end
end