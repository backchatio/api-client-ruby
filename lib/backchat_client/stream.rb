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

    ##
    # Constructor
    #
    # ==== Parameters
    # * *api_key* application identifier
    # * *endpoint* Backchat endpoint
    #
    # ==== Return
    # * *Stream* instance
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
    # @return decoded response body
    def create(name, description, filters = [])
      begin
        data = post("", {:name => name, :description => description, :channel_filters => filters})
        ActiveSupport::JSON.decode(data)
      rescue Error::ClientError => ex
        logger.error ActiveSupport::JSON.decode(ex.response.body)
        raise ex
      end
    end

    # Retrieves a stream
    # @param *name* get a stream
    # @return stream data or nil if not found
    def find(name)
      name.nil? and name = "index.json"
      begin
        ActiveSupport::JSON.decode(get(name))
      rescue Error::ClientError => ex
        logger.error(ex.errors)
        return nil
      end
    end

    def update(slug, params)
      ActiveSupport::JSON.decode(put(slug, params))
    end

    ##
    # Delete a defined stream
    #
    # ==== Parameters
    # * *name* valid stream name
    # ==== Return
    # * true|false if deleted or not
    def destroy(name)
      begin
        delete(name)
        true
      rescue Error::ClientError => ex
        logger.error ex.errors
        false
      end
    end

  end
end