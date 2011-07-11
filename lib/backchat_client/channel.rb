require 'backchat_client/http_client'
require 'active_support'

module BackchatClient
  class Channel
    include BackchatClient::HttpClient
    
    URI_PATH = "channels"

    def initialize(api_key, endpoint)
      @api_key = api_key
      @endpoint = endpoint
    end

    # This method POST a request to create a new channel on behalf of the
    # authenticated application
    # @param uri valid Backchat URI, i.e. twitter://username
    # @return response body
    def create(uri)
      ActiveSupport::JSON.decode(post("index.json", {:channel => uri}))
    end
    
    # This method sends a GET request to retrieve all or a specific application
    # channel
    # @TODO use the parameter
    # @return response body
    def find(name)
      ActiveSupport::JSON.decode(get("index.json"))
    end

    def destroy(name, force = false)
      begin
        ActiveSupport::JSON.decode(delete("",{:channel => name, :force  => force}))
        return true
      rescue RestClient::ResourceNotFound
        return false
      end
    end
    
  end
end