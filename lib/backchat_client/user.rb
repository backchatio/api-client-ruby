require 'active_support'

module BackchatClient
  class User
    include BackchatClient::HttpClient

    URI_PATH = ""    

    def initialize(api_key, endpoint)
      @api_key = api_key
      @endpoint = endpoint
    end
    

    def create(username)
    end
    
    def find
      ActiveSupport::JSON.decode(get("index.json"))["data"]
    end
  end
end