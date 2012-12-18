# shrimp.rb
require 'pagelime'
require 'rack'

module Rack

	class Pagelime

		def initialize(app)
			puts "PAGELIME: Rack Plugin Initialized"
			@app = app 
		end 

		def call(env)

	    	@status, @headers, @response = @app.call(env)
			
			req = Rack::Request.new(env)

			puts "PAGELIME: Processing For Path: #{req.path}"
			puts "PAGELIME: Processing Body (size:#{req.body.length})"
			body = cms_process_html_block(req.path, req.body, false)

	        @headers['content-length'] = bytesize(body).to_s

	    	return [@status,@headers,body]
		end

	end

end