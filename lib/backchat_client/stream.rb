require 'active_support'
require 'rest_client'

module BackchatClient
  class Stream
    
    URI_PATH = "streams"
    
    def initialize(api_key, endpoint)
      @api_key = api_key
      @endpoint = endpoint
    end
    
    def create(name, description, filters = [], filter_enabled = [])
      ActiveSupport::JSON.decode(post("", {:name => name, :description => description, :channel_filters => filters, :filter_enabled => filter_enabled}))
    end
    
    def find(name)
      ActiveSupport::JSON.decode(get("index.json"))
    end
    
    def destroy(name)
      begin
        ActiveSupport::JSON.decode(delete(name))
        return true
      rescue RestClient::ResourceNotFound
        return false
      end
    end
    
    private
    
    def get(path, params = nil, headers = {})
      headers.merge!({:Authorization => "Backchat #{@api_key}"})
      RestClient.get("#{@endpoint.concat(URI_PATH)}/#{path}", headers)
    end

    def post(path, body = {}, headers = {})
      headers.merge!({:Authorization => "Backchat #{@api_key}", :content_type => :json, :accept => :json})
      RestClient.post("#{@endpoint.concat(URI_PATH)}/#{path}", ActiveSupport::JSON.encode(body), headers)
    end   
    
    def delete(path, body = {}, headers = {})
      headers.merge!({:Authorization => "Backchat #{@api_key}"})
      RestClient.delete("#{@endpoint.concat(URI_PATH)}/#{path}", headers)
    end   
     
  end
end