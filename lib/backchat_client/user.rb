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
    
    # this method return the user profile in case that the token provided is valid
    # @return user profile with information about channels, streams and plan
    # @return nil if token is invalid
    def find
      begin
        data = get("index.json")
        if data.is_a?(String)
          data = ActiveSupport::JSON.decode(data)
          if data.has_key?("data")
            data["data"]
          else
            nil
          end
        end
      rescue RestClient::Unauthorized => ex
        # Invalid token
        nil
      rescue Exception => ex
        # Unknown error. Should be logged
        defined? logger and logger.error ex
        nil
      end
    end
  end
end