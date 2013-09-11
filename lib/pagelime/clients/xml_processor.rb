require "nokogiri"

module Pagelime
  module Clients
    class XmlProcessor
      
      def process_document(storage, html, page_path = false)
        Pagelime.logger.debug "PAGELIME CMS RACK PLUGIN: Document HTML: #{html.inspect}"
        
        doc = Nokogiri::HTML::Document.parse(html)
        
        # return original HTML if nil returned
        output = parse_document(storage, doc, page_path) || html
        
        if html == output
          Pagelime.logger.debug "PAGELIME CMS RACK PLUGIN: Document output: UNCHANGED!"
        else
          Pagelime.logger.debug "PAGELIME CMS RACK PLUGIN: Document output: #{output.inspect}"
        end
        
        output
      end
      
      def process_fragment(storage, html, page_path = false)
        Pagelime.logger.debug "PAGELIME CMS RACK PLUGIN: Fragment HTML: #{html.inspect}"
        
        doc = Nokogiri::HTML::DocumentFragment.parse(html)
        
        # return original HTML if nil returned
        output = parse_document(storage, doc, page_path) || html
        
        if html == output
          Pagelime.logger.debug "PAGELIME CMS RACK PLUGIN: Fragment output: UNCHANGED!"
        else
          Pagelime.logger.debug "PAGELIME CMS RACK PLUGIN: Fragment output: #{output.inspect}"
        end
        
        output
      end
      
      private
      
      def parse_document(storage, doc, page_path = false)
        editable_content  = storage.fetch_path(page_path)
        shared_content    = storage.fetch_shared
        
        unless editable_content || shared_content
          ::Pagelime.logger.warn "PAGELIME CMS RACK PLUGIN: Content not returned from storage"
          return nil
        end
      
        # use nokogiri to replace contents
        editable_regions  = doc.css(".cms-editable")
        shared_regions    = doc.css(".cms-shared")
        
        patch_regions editable_regions, editable_content
        patch_regions shared_regions, shared_content
          
        doc.to_html
      end
      
      def patch_regions(editable_regions, xml_content)
      
        ::Pagelime.logger.debug "PAGELIME CMS RACK PLUGIN: parsing xml"
      
        editable_regions.each do |div| 
        
          # Grab content ID
          content_id = div["id"]
          soap      = Nokogiri::XML::Document.parse(xml_content)
          nodes     = soap.css("EditableRegion[@ElementID=\"#{content_id}\"]")
          
          ::Pagelime.logger.debug "PAGELIME CMS RACK PLUGIN: looking for region: #{content_id}"
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
end