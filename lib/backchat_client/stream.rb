require 'backchat_client/http_client'
require 'backchat_client/backchat_logger'
require 'active_support'

module BackchatClient

  #
  # A Backchat Stream allows to define a set of channels with filters
  #
  class Stream
    include BackchatClient::HttpClient
    include BackchatClient::BackchatLogger

    # http uri to handle streams
    URI_PATH = "streams"

    #
    # @param *api_key* application identifier
    # @param *endpoint* Backchat endpoint
    #
    def initialize(api_key, endpoint)
      @api_key = api_key
      @endpoint = endpoint
    end

    #
    # This method POST a request to create a new stream on behalf of the
    # authenticated application
    # @param name
    # @param description
    # @param filters one or more valid channel URIs
    # @param filter_enabled one or more boolean values enabling|disabling the filters
    # @return response body
    #
    def create(name, description, filters = [])
      ActiveSupport::JSON.decode(post("", {:name => name, :description => description, :channel_filters => filters}))
    end

    #
    # Retrieves a stream
    # @param *name* get a stream
    # @return stream data or nil if not found
    #
    def find(name)
      if name
        begin
          ActiveSupport::JSON.decode(get(name))
        rescue RestClient::ResourceNotFound
          return nil
        end
      else
        ActiveSupport::JSON.decode(get("index.json"))
      end
    end

    def update(slug, params)
      ActiveSupport::JSON.decode(put(slug, params))
    end

    #
    # Delete a defined stream
    # @param *name* valid stream name
    # @param true|false if deleted or not
    #
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