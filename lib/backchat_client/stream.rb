require 'backchat_client/http_client'
require 'active_support'

module BackchatClient
  class Stream
    include BackchatClient::HttpClient
    
    URI_PATH = "streams"
    
    def initialize(api_key, endpoint)
      @api_key = api_key
      @endpoint = endpoint
    end
    
    # This method POST a request to create a new stream on behalf of the
    # authenticated application
    # @param name
    # @param description
    # @param filters one or more valid channel URIs
    # @param filter_enabled one or more boolean values enabling|disabling the filters
    # @return response body
    def create(name, description, filters = [])
      # TODO include filter_enabled = true when there're empty spaces
      ActiveSupport::JSON.decode(post("", {:name => name, :description => description, :channel_filters => filters}))
    end
    
    def find(name)
      ActiveSupport::JSON.decode(get("index.json"))
    end
    
    def update(slug, params)
      ActiveSupport::JSON.decode(put(slug, params))
    end
    
    def destroy(name)
      begin
        ActiveSupport::JSON.decode(delete(name))
        return true
      rescue RestClient::ResourceNotFound
        return false
      end
    end
    
  end
end