# shrimp.rb
require 'pagelime'
require 'rack'
require 'rack/utils'

module Rack
  class Pagelime
    include Rack::Utils

    def initialize(app, opts = {})
      @app = app
      @opts = {
        :log => false
      }
      @opts.merge! opts
      
      log "PAGELIME: Rack Plugin Initialized"
    end 

    def call(env)

      status, headers, response = @app.call(env)

      log "PAGELIME: Headers: #{headers}"
      log "PAGELIME: Status: #{status}"
      log "PAGELIME: Response: #{response}"

      if status == 200 && headers["content-type"].include?("text/html")
          
        body_content = ""
        response.each{|part| body_content += part}
    
        req = Rack::Request.new(env)

        log "PAGELIME: Processing For Path: #{req.path}"
        log "PAGELIME: Processing Body (size:#{body_content.length})"
      
        body = cms_process_html_block(:page_path => req.path, :html => body_content, :fragment => false)

        headers['content-length'] = body.length.to_s

        return [status,headers,[body]]

      else

        log "PAGELIME: Not touching this request"

        return [status,headers,response]

      end

    end
    
    private
    
    def log(*values)
      if @opts[:log] == "verbose"
        puts(*values)
      end
    end

  end

end