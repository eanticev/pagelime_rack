require 'rack'
require 'rack/utils'

require_relative '../pagelime'

module Rack
  class Pagelime
    include Rack::Utils
    
    ENV_KEYS = {
      :toggle_processing => "pagelime.toggle_processing"
    }
    
    module ClassMethods
      def enable_processing_for_request(req)
        req.env[ENV_KEYS[:toggle_processing]] = "on"
      end
      
      def disable_processing_for_request(req)
        req.env[ENV_KEYS[:toggle_processing]] = "off"
      end
      
      def processing_enabled_for_request?(req)
        config_option = ::Pagelime.config.toggle_processing
        config_option = req.env[ENV_KEYS[:toggle_processing]] if config_option == "per_request"
        
        ::Pagelime.logger.debug  "PAGELIME CMS RACK PLUGIN: Procesing enabled for request? (config: #{::Pagelime.config.toggle_processing}, env: #{req.env[ENV_KEYS[:toggle_processing]]}, evaluated as: #{config_option})"
        
        return config_option == "on"
      end
      
      # responses
      
      def handle_route(req)
        if req.get?
          path    = req.path.gsub(/\A\/+|\/+\Z/, "")
          prefix  = ::Pagelime.config.url_path.gsub(/\A\/+|\/+\Z/, "")
          action  = path["#{prefix}/".size..-1].to_s
          
          # hijack response if a pagelime route, otherwise process output if so required
          if path.start_with?("#{prefix}/") || path == prefix
            case action
            # handle publish callback
            when "after_publish_callback"
              resp = handle_publish_callback(req)
            # handle "index"
            when ""
              resp = handle_status_check(req)
            else
              ::Pagelime.logger.debug  "PAGELIME CMS RACK PLUGIN: Unable to route action! (URL prefix: #{::Pagelime.config.url_path}, Request path: #{req.path})"
            end
          else
            ::Pagelime.logger.debug  "PAGELIME CMS RACK PLUGIN: Unable to route prefix! (URL prefix: #{::Pagelime.config.url_path}, Request path: #{req.path})"
          end
        end
        
        resp
      end
      
      def handle_publish_callback(req)
        
        ::Pagelime.logger.debug  "PAGELIME CMS RACK PLUGIN: Route for publish callback called!"
        
        ::Pagelime.cache.clear_page(req.params["path"].to_s)
        ::Pagelime.cache.clear_shared
        
        [200, {"Content-Type" => "text/html"}, ["cache cleared"]]
      end
      
      def handle_status_check(req)
        
        ::Pagelime.logger.debug  "PAGELIME CMS RACK PLUGIN: Route for index called!"
        
        [200, {"Content-Type" => "text/html"}, ["working"]]
      end
      
    end
    
    include ClassMethods
    extend ClassMethods
    
    def initialize(app)
      @app = app
      
      ::Pagelime.logger.debug  "PAGELIME CMS RACK PLUGIN: Rack Plugin Initialized"
    end 

    def call(env)
      
      app_resp  = @app.call(env)
      req       = Rack::Request.new(env)
      resp      = handle_route(req)
      
      # only process original output if routing wasn't handled
      unless resp
        
        status, headers, response = app_resp
      
        ::Pagelime.logger.debug  "PAGELIME CMS RACK PLUGIN: Headers: #{headers}"
        ::Pagelime.logger.debug  "PAGELIME CMS RACK PLUGIN: Status: #{status.inspect}"
        ::Pagelime.logger.debug  "PAGELIME CMS RACK PLUGIN: Response: #{response}"
        
        if status == 200 && headers["Content-Type"].to_s.include?("text/html") && processing_enabled_for_request?(req)
            
          html = ""
          response.each{|part| html << part}
          
          ::Pagelime.logger.debug "PAGELIME CMS RACK PLUGIN: Processing For Path: #{req.path}"
          ::Pagelime.logger.debug "PAGELIME CMS RACK PLUGIN: Processing Body (size:#{html.length})"
          ::Pagelime.logger.debug "PAGELIME CMS RACK PLUGIN: Processing Body: #{html.inspect}"
        
          html = ::Pagelime.process_page(html, req.path)
  
          headers['content-length'] = html.length.to_s
  
          body = [html]
          
        else
  
          ::Pagelime.logger.debug  "PAGELIME CMS RACK PLUGIN: Not touching this request"
  
          body = response
  
        end
        
        resp = [status, headers, body]
        
      end
      
      resp
    end
    
  end

end