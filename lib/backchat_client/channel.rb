require 'backchat_client/http_client'
require 'active_support'
require 'backchat_client/backchat_logger'

module BackchatClient

  #
  # A Backchat Channel allows to define an external resource to fetch events using Backchat infrastructure
  #
  class Channel
    include BackchatClient::HttpClient
    include BackchatClient::BackchatLogger

    # http uri to handle channels
    URI_PATH = "channels"

    #
    # @param *api_key* application identifier
    # @param *endpoint* Backchat endpoint
    #
    def initialize(api_key, endpoint)
      @api_key = api_key
      @endpoint = endpoint
    end

    #
    # This method POST a request to create a new channel on behalf of the
    # authenticated application
    # @param uri valid Backchat URI, i.e. twitter://username
    # @return response body
    #
    def create(uri)
      ActiveSupport::JSON.decode(post("index.json", {:channel => uri}))
    end

    #
    # This method sends a GET request to retrieve all the user channels
    # There is no way to retrieve a specific channel
    # @return response body
    #
    def find
      ActiveSupport::JSON.decode(get("index.json"))
    end

    #
    # Delete an application channel
    # @param *name* valid channel URI
    # @param *force* delete even if it is being used by a stream
    # @return true|false
    #
    def destroy(name, force = false)
      begin
        ActiveSupport::JSON.decode(delete("", {:channel => name, :force => force}))
        return true
      rescue RestClient::ResourceNotFound
        return false
      end
    end

  end
end