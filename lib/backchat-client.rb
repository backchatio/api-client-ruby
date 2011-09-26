require 'backchat_client/channel'
require 'backchat_client/stream'
require 'backchat_client/user'
require 'backchat_client/backchat_logger'
require 'backchat_client/error'
require 'addressable/uri'

module Backchat

  include BackchatClient::BackchatLogger
  
  autoload :ClientError, 'error/client_error'

  ##
  # This class is the main entry point to use the backchat-client gem.
  # It creates a client with a specific api_key that connects to Backchat
  # and processes any request.
  #
  class Client
    include BackchatClient::BackchatLogger

    # default endpoint where Backchat is deployed
    DEFAULT_ENDPOINT = "https://api.backchat.io/1"

    # api key that identifies any request
    attr_accessor :api_key

    # endpoint to access to Backchat
    attr_reader :endpoint

    ##
    # Constructor
    # ==== Parameters
    # * *api_key* application identifier
    # * *endpoint* Backchat endpoint
    # ==== Return
    # * *Client* instance
    #
    def initialize(api_key, endpoint = nil)
      @_valid = nil
      @api_key = api_key
      @endpoint = endpoint || DEFAULT_ENDPOINT
    end

    ##
    # Checks if the api_key is valid
    # ==== Return
    # * true if valid, false if invalid
    def valid?
      @_valid.nil? ? @_valid = !get_profile.nil? : @_valid
    end

    ##
    # === *User management*

    ##
    # Get user profile.
    # The api_key used should be associated to a user
    # ==== Return
    # * user profile or nil if invalid api_key
    def get_profile
      user.find
    end

    ##
    # Delete user account
    # The api_key used should be associated to a user
    def delete_user
      user.destroy
    end

    ##
    # === *Channels management*

    ##
    # Retrieves a specific channel or all the channels associated to the api_key
    # ==== Return
    # * one or more channel data
    # * nil if unable to retrieve valid data
    def find_channel
      channels = channel.find

      # check that the data has the expected format
      if channels.respond_to?("has_key?") and channels.has_key?("data")
        channels["data"]
      else
        logger.info("Unable to find channels")
        nil
      end
    end

    ##
    # Creates a specific channel in Backchat
    #
    # ==== Parameters
    # * *uri*: Full URI of the channel: <type>://<address>
    # * *filter*: optional backchat filter
    #
    # ==== Return
    # * response body returned by Backchat
    # * BackchatClient::Error::ClientError if invalid data
    # * BackchatClient::Error::GeneralError if unable to retrieve a valid response
    def create_channel(uri, filter = nil)
      
      filter.nil? or uri = uri.concat("?q=#{filter}")

      uri = Addressable::URI.parse(uri).normalize.to_s
      
      _channel = channel.create(uri)

      if _channel.respond_to?("has_key?") and _channel.has_key?("data")
        logger.debug("Channel created in Backchat #{_channel}")
        _channel["data"]
      else
        logger.error("Invalid data received while creating channel #{_channel}")
        raise BackchatClient::Error::GeneralError.new("No data received from Backchat while creating channel")
      end
    end

    ##
    # Delete a channel in Backchat
    #
    # ==== Parameters
    # * *uri* valid channel uri
    # * *force* true|false if channel should be deleted even if being used in a stream
    # ==== Return
    # * true if channel was deleted
    # * false if there was an error
    def destroy_channel(uri, force = false)
      channel.destroy(uri, force)
    end

    ##
    # === *Streams management*

    ##
    # Retrieves a specific stream
    # @param *name* (optional) stream name. If undefined, all the user streams are retrieved
    # @return stream data hash
    def find_stream(name = nil)
      streams = stream.find(name)

      if !streams.nil? and streams.respond_to?("has_key?") and streams.has_key?("data")
        streams["data"]
      else
        logger.debug "Stream with name #{name} not found in backchat"
        nil
      end
    end

    ##
    # Create a specific stream
    #
    # ==== Parameters
    # * *name* unique stream identifier
    # * *description* (optional)
    # * *filters* (optional) array of filters
    def create_stream(name, description = nil, filters = [])
      description.nil? and description = "Stream created using backchat-client gem"
      begin
        _stream = stream.create(name, description, filters)
        if _stream.respond_to?("has_key?") and _stream.has_key?("data")
          _stream["data"]
        else
          logger.error("Invalid data received while creating stream: #{_stream}")
          raise BackchatClient::Error::GeneralError.new("No data received from Backchat while creating stream")
        end
      rescue BackchatClient::Error::ClientError => ex
        logger.error("There was an error creating the stream: #{ex.errors}")
        nil
      end
    end
    
    ##
    # Deletes a specific well defined channel from a Backchat stream
    #
    # ==== Parameters
    # *channel*: channel URI to delete
    # *stream_slug* (optional): stream where the channel should be deleted (optional as it can be defined
    #              using the api_key)
    #
    # ==== Return
    # * *boolean* true if the stream was successfully updated, false in case of failure
    #
    def delete_channel_from_stream(channel, stream_slug = nil)
      st = find_stream(stream_slug) or raise BackchatClient::Error::NotFoundError.new("stream does not exist")
      
      if st.is_a?(Array)
        st = st.pop
      end
      
      channel = Addressable::URI.parse(channel).normalize.to_s
      
      logger.debug "delete_channel_from_stream: delete channel #{channel} with initial filters #{st['channel_filters']}"
      st["channel_filters"].delete_if{|c|
        c["channel"].eql?(channel)
      }
      
      st["channel_filters"].map! { |channel|
        channel[:channel] = Addressable::URI.parse(channel["expanded"]["canonical_uri"]).normalize.to_s
        channel[:q] = channel["expanded"]["params"]["q"]
        channel[:recorded] = true
        channel.delete_if{|k| ![:channel, :q, :recorded].include?(k)}
      }
      
      logger.debug "delete_channel_from_stream: updated filters #{st['channel_filters']}"
      stream.update(st["slug"], st)
    end

    ##
    # This method updates the stream, assigning the new channels array to it.
    # In order to simplify, all the channels received will be automatically enabled.
    #
    # ==== Parameters
    # * *stream_slug* stream name
    # * *channels* array of channels to be included in the stream
    # * *reset* the channels are added (false) to the current channels or remove (true) the previous ones
    # * *filter* valid Lucene syntax to filter the channels
    #
    # ==== Return
    # * *boolean* true if the stream was successfully updated, false in case of failure
    #
    def set_channels(stream_slug, channels = [], reset = false, filter = nil)
      st = stream.find(stream_slug) or raise "stream does not exist"

      logger.debug("Updating includind reset = #{reset} channels of stream #{stream_slug}")

      st = st["data"]
      # format the channels array
      channels.map { |channel|
        channel[:channel] = Addressable::URI.parse(channel[:channel]).normalize.to_s
        channel[:recorded] = true
        channel[:q] = filter unless filter.nil? or filter.empty?
      }

      if reset
        # reset the stream channels
        st["channel_filters"] = channels
      else
        # add the new channels to the existing ones
        previous_channels = st["channel_filters"]
        previous_channels.map!{|channel|
          channel[:channel] = Addressable::URI.parse(channel["expanded"]["canonical_uri"]).normalize.to_s
          channel[:q] = channel["expanded"]["params"]["q"]
          channel[:recorded] = true
          channel.delete_if{|k| ![:channel, :q, :recorded].include?(k)}
        }
        st["channel_filters"] = previous_channels + channels
      end

      begin
        logger.debug("Updating stream channels to #{st}")
        stream.update(stream_slug, st)
        true
      rescue Exception => ex
        logger.error("Error while updating stream channels : #{ex.errors}")
        false
      end

    end

    ##
    # Delete a stream
    #
    # ==== Parameters
    # * *name* stream name
    def destroy_stream(name)
      stream.destroy(name)
    end

    private

    # Composition pattern

    # user management object
    def user
      @user ||= BackchatClient::User.new(api_key, endpoint.dup)
    end

    # channel management object
    def channel
      @channel ||= BackchatClient::Channel.new(api_key, endpoint.dup)
    end

    # stream management object
    def stream
      @stream ||= BackchatClient::Stream.new(api_key, endpoint.dup)
    end

  end
end
