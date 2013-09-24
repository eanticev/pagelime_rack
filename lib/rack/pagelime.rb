require 'rack'
require 'rack/utils'

require_relative '../pagelime'

module Rack
  class Pagelime
    include Rack::Utils
    
    TOGGLE_PROCESSING_ENV_KEY = "pagelime.toggle_processing"
    
    module ClassMethods
      def enable_processing_for_request(env)
        env[TOGGLE_PROCESSING_ENV_KEY] = "on"
      end
      
      def disable_processing_for_request(env)
        env[TOGGLE_PROCESSING_ENV_KEY] = "off"
      end
      
      def processing_enabled_for_request?(env)
        config_option = ::Pagelime.config.toggle_processing
        config_option = env[TOGGLE_PROCESSING_ENV_KEY] if config_option == "per_request"
        
        ::Pagelime.logger.debug  "PAGELIME CMS RACK PLUGIN: Procesing enabled for request? (config: #{::Pagelime.config.toggle_processing}, env: #{env[TOGGLE_PROCESSING_ENV_KEY]}, evaluated as: #{config_option})"
        
        return config_option == "on"
      end
    end
    
    include ClassMethods
    extend ClassMethods
    
    def initialize(app)
      @app = app
      
      ::Pagelime.logger.debug  "PAGELIME CMS RACK PLUGIN: Rack Plugin Initialized"
    end 

    def call(env)
      
      status, headers, response = @app.call(env)

      req     = Rack::Request.new(env)
      path    = req.path.gsub(/\A\/+|\/+\Z/, "")
      prefix  = ::Pagelime.config.url_path.gsub(/\A\/+|\/+\Z/, "")
      action  = path["#{prefix}/".size..-1].to_s
      
      # hijack response if a pagelime route, otherwise process output if so required
      if path.start_with?("#{prefix}/") || path == prefix
        case action
        # handle publish callback
        when "after_publish_callback"
          resp = handle_publish_callback(status, headers, response, env)
        # handle "index"
        when ""
          resp = handle_status_check(status, headers, response, env)
        else
          ::Pagelime.logger.debug  "PAGELIME CMS RACK PLUGIN: Unable to route action! (URL prefix: #{::Pagelime.config.url_path}, Request path: #{req.path})"
        end
      else
        ::Pagelime.logger.debug  "PAGELIME CMS RACK PLUGIN: Unable to route prefix! (URL prefix: #{::Pagelime.config.url_path}, Request path: #{req.path})"
      end
      
      # only process original output if routing wasn't handled
      resp ||= handle_html_processing(status, headers, response, env)
      
      resp
    end
    
    # responses
    
    def handle_publish_callback(status, headers, response, env)
      
      req = Rack::Request.new(env)

      ::Pagelime.logger.debug  "PAGELIME CMS RACK PLUGIN: Route for publish callback called!"
      
      ::Pagelime.cache.clear_page(req.params["path"].to_s)
      ::Pagelime.cache.clear_shared
      
      [200, {"Content-Type" => "text/html"}, ["cache cleared"]]
    end
    
    def handle_status_check(status, headers, response, env)
      
      req = Rack::Request.new(env)

      ::Pagelime.logger.debug  "PAGELIME CMS RACK PLUGIN: Route for index called!"
      
      [200, {"Content-Type" => "text/html"}, ["working"]]
    end
    
    def handle_html_processing(status, headers, response, env)
      
      req = Rack::Request.new(env)

      status, headers, response = @app.call(env)

      ::Pagelime.logger.debug  "PAGELIME CMS RACK PLUGIN: Headers: #{headers}"
      ::Pagelime.logger.debug  "PAGELIME CMS RACK PLUGIN: Status: #{status}"
      ::Pagelime.logger.debug  "PAGELIME CMS RACK PLUGIN: Response: #{response}"
      
      if processing_enabled_for_request?(env) && status == 200 && 
         headers["content-type"] && headers["content-type"].include?("text/html")
          
        body_content = StringIO.new(response)
        #response.each{|part| body_content << part}
        
        ::Pagelime.logger.debug  "PAGELIME CMS RACK PLUGIN: Processing For Path: #{req.path}"
        ::Pagelime.logger.debug  "PAGELIME CMS RACK PLUGIN: Processing Body (size:#{body_content.length})"
      
        body = ::Pagelime.process_page(body_content, req.path)

        headers['content-length'] = body.length.to_s

        body = [body]

      else

        ::Pagelime.logger.debug  "PAGELIME CMS RACK PLUGIN: Not touching this request"

        body = response

      end
      
      [status, headers, body]
      
    end
    
  end

end