require 'rest_client'

module BackchatClient
  #
  # This module sends HTTP requests to Backchat including the specific
  # header authenticating the sender
  # It's just a mixin, some features must be pre-loaded in the entity that uses
  # the mixin
  # @endpoint: Backchat API URI: https://api.backchat.io
  # @api_key: application api key: kljdfjrwerwlkdfjsldkf
  # URI_PATH: entity/model specific: streams, channels, etc.
  #
  module HttpClient

    # HTTP GET
    def get(path, params = nil, headers = {})
      headers.merge!({:Authorization => "Backchat #{@api_key}"})
      RestClient.get("#{@endpoint.concat(uri_path)}/#{path}", headers)
    end

    # HTTP POST
    def post(path, body = {}, headers = {})
      headers.merge!({:Authorization => "Backchat #{@api_key}", :content_type => :json, :accept => :json})
      RestClient.post("#{@endpoint.concat(uri_path)}/#{path}", ActiveSupport::JSON.encode(body), headers)
      puts "#{@endpoint}/#{uri_path}/#{path}"
      puts ActiveSupport::JSON.encode(body)
    end   
    
    # HTTP DELETE
    def delete(path, body = {}, headers = {})
      headers.merge!({:Authorization => "Backchat #{@api_key}"})
      RestClient.delete("#{@endpoint.concat(uri_path)}/#{path}", headers)
    end   
    
    private
    
    # Returns the entity URI_PATH constant (loaded from the entity class)
    def uri_path
      (defined? self.class::URI_PATH).nil? and raise RuntimeError.new "URI_PATH constant should be defined"      
      self.class::URI_PATH
    end
     
  end
end