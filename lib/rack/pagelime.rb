require 'rack'
require 'rack/utils'

require_relative '../pagelime'

module Rack
  class Pagelime
    include Rack::Utils

    def initialize(app, options = {})
      @app      = app
      @options  = options
      
      ::Pagelime.logger.debug  "PAGELIME CMS RACK PLUGIN: Rack Plugin Initialized"
    end 

    def call(env)

      status, headers, response = @app.call(env)

      ::Pagelime.logger.debug  "PAGELIME CMS RACK PLUGIN: Headers: #{headers}"
      ::Pagelime.logger.debug  "PAGELIME CMS RACK PLUGIN: Status: #{status}"
      ::Pagelime.logger.debug  "PAGELIME CMS RACK PLUGIN: Response: #{response}"

      if status == 200 && headers["content-type"].include?("text/html")
          
        body_content = StringIO.new
        response.each{|part| body_content << part}
    
        req = Rack::Request.new(env)

        ::Pagelime.logger.debug  "PAGELIME CMS RACK PLUGIN: Processing For Path: #{req.path}"
        ::Pagelime.logger.debug  "PAGELIME CMS RACK PLUGIN: Processing Body (size:#{body_content.length})"
      
        body = ::Pagelime.process_page(body_content, req.path)

        headers['content-length'] = body.length.to_s

        return [status, headers, [body]]

      else

        ::Pagelime.logger.debug  "PAGELIME CMS RACK PLUGIN: Not touching this request"

        return [status, headers, response]

      end

    end
    
  end

end