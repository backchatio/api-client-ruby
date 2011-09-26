require 'backchat_client/http_client'
require 'active_support'
require 'backchat_client/backchat_logger'

module BackchatClient

  ##
  # A Backchat Channel allows to define an external resource to fetch events using Backchat infrastructure
  #
  class Channel
    include BackchatClient::HttpClient
    include BackchatClient::BackchatLogger

    # http uri to handle channels
    URI_PATH = "channels"

    ##
    # Constructor
    #
    # ==== Parameters
    # * *api_key* application identifier
    # * *endpoint* Backchat endpoint
    #
    # ==== Return
    # * *Channel* instance
    def initialize(api_key, endpoint)
      @api_key = api_key
      @endpoint = endpoint
    end

    ##
    # This method POST a request to create a new channel on behalf of the
    # authenticated application
    # ==== Parameters
    # * *uri*: Full URI of the channel: <type>://<address> including the filter
    #
    # ==== Return
    # * JSON decoded response body returned by Backchat
    # * BackchatClient::Error::ClientError if invalid data
    def create(uri)
      begin
        data = post("index.json", {:channel => uri})
        ActiveSupport::JSON.decode(data)
      rescue Error::ClientError => ex
        logger.error ex.errors
        raise ex
      end
    end

    ##
    # Sends a GET request to retrieve all the user channels
    # Currently there is no way to retrieve a specific channel
    # ==== Return
    # * response body
    def find
      ActiveSupport::JSON.decode(get("index.json"))
    end

    ##
    # Delete a channel in Backchat
    #
    # ==== Parameters
    # * *uri* valid channel URI
    # * *force* true|false if channel should be deleted even if being used by a stream
    # ==== Return
    # * true if channel was deleted, false if there was an error
    def destroy(uri, force = false)
      begin
        delete("", {:channel => uri, :force => force})
        true
      rescue Error::ClientError => ex
        logger.error ex.errors
        false
      end
    end

  end
end