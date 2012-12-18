# shrimp.rb
require 'pagelime'
require 'rack'
require 'rack/utils'

module Rack

	class Pagelime
    	
    	include Rack::Utils

		def initialize(app, opts = {})
			puts "PAGELIME: Rack Plugin Initialized"
			@app = app
			@opts = {
				:log => false,
			}
			@opts.merge! opts
		end 

		def call(env)

	    	status, headers, response = @app.call(env)

	    	if (@opts[:log] == "verbose") 
	    		puts "PAGELIME: Headers: #{headers}"
	    		puts "PAGELIME: Status: #{status}"
	    		puts "PAGELIME: Response: #{response}"
	    	end

	    	if status == 200 && headers["content-type"].include?("text/html")
        		
        		body_content = ""
        		response.each { |part| body_content += part }
			
				req = Rack::Request.new(env)

	    		if (@opts[:log] == "verbose") 
					puts "PAGELIME: Processing For Path: #{req.path}"
					puts "PAGELIME: Processing Body (size:#{body_content.length})"
				end

				body = cms_process_html_block(req.path, body_content, false)

		        headers['content-length'] = body.length.to_s

		    	return [status,headers,[body]]

	    	else

	    		if (@opts[:log] == "verbose") 
					puts "PAGELIME: Not touching this request"
				end

		    	return [status,headers,response]

		    end

		end

	end

end