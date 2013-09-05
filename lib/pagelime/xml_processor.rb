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
      Pagelime.logger.debug "PAGELIME CMS RACK PLUGIN: Document HTML: #{html.inspect}"
      
      doc = Nokogiri::HTML::Document.parse(html)
      
      # return original HTML if nil returned
      output = parse_document(doc, page_path) || html
      
      if html == output
        Pagelime.logger.debug "PAGELIME CMS RACK PLUGIN: Document output: UNCHANGED!"
      else
        Pagelime.logger.debug "PAGELIME CMS RACK PLUGIN: Document output: #{output.inspect}"
      end
      
      output
    end
    
    def process_fragment(html, page_path = false)
      Pagelime.logger.debug "PAGELIME CMS RACK PLUGIN: Fragment HTML: #{html.inspect}"
      
      doc = Nokogiri::HTML::DocumentFragment.parse(html)
      
      # return original HTML if nil returned
      output = parse_document(doc, page_path) || html
      
      if html == output
        Pagelime.logger.debug "PAGELIME CMS RACK PLUGIN: Fragment output: UNCHANGED!"
      else
        Pagelime.logger.debug "PAGELIME CMS RACK PLUGIN: Fragment output: #{output.inspect}"
      end
      
      output
    end
    
    private
    
    # options = { :page_path => nil, :html => "", :fragment => true }
    def parse_document(doc, page_path = false)
      
      unless client.configured?
        ::Pagelime.logger.warn "PAGELIME CMS RACK PLUGIN: Environment variables not configured"
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
    
      ::Pagelime.logger.debug "PAGELIME CMS RACK PLUGIN: parsing xml"
    
      editable_regions.each do |div| 
      
        # Grab client ID
        client_id = div["id"]
        soap      = Nokogiri::XML::Document.parse(xml_content)
        nodes     = soap.css("EditableRegion[@ElementID=\"#{client_id}\"]")
        
        ::Pagelime.logger.debug "PAGELIME CMS RACK PLUGIN: looking for region: #{client_id}"
        ::Pagelime.logger.debug "PAGELIME CMS RACK PLUGIN: regions found: #{nodes.count}"
    
        if nodes.any?
          new_content = nodes[0].css("Html")[0].content
          
          ::Pagelime.logger.debug "PAGELIME CMS RACK PLUGIN: NEW CONTENT: #{new_content.inspect}"
          
          if new_content
            # div.content = "Replaced content"
            div.replace new_content
          end
        end
      
      end
  
    end
    
  end
end