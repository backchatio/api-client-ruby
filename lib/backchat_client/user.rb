require 'active_support'
require 'backchat_client/backchat_logger'

module BackchatClient
  class User
    include BackchatClient::HttpClient
    include BackchatClient::BackchatLogger

    URI_PATH = nil # no suffix for user path

    def initialize(api_key, endpoint)
      @api_key = api_key
      @endpoint = endpoint
    end
    
    # this method return the user profile in case that the token provided is valid
    # @return user profile with information about channels, streams and plan
    # @return nil if token is invalid or an unexpected error takes place
    def find
      begin
        debug("Fetching user profile")
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
        error "Invalid api_key #{@api_key}"
        nil # Invalid token
      rescue Exception => ex
        logger.error " Unexpected error"
        logger.error ex.inspect
        nil # Unexpected error
      end
    end
  end
end