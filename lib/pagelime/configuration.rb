module Pagelime
  class Configuration
    
    attr_accessor :account_key, :account_secret, :api_version
    
    def initialize
      account_key     = ENV['PAGELIME_ACCOUNT_KEY']
      account_secret  = ENV['PAGELIME_ACCOUNT_SECRET']
      api_version     = ENV['PAGELIME_RACK_API_VERSION']
    end
    
    def configured?
      !(account_key.nil? || account_secret.nil? || api_version.nil?)
    end
  end
end