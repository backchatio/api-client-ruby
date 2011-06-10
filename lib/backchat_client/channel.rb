require 'rest_client'

module BackchatClient
  class Channel
    
    URI_PATH = "/channels"

    def initialize(api_key, endpoint)
      @api_key = api_key
      @endpoint = endpoint
    end

    def create(uri)
      ActiveSupport::JSON.decode(post("index.json", {:channel => uri}))
    end
    
    def find(name)
      ActiveSupport::JSON.decode(get("index.json"))
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
    
  end
end