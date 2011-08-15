require 'backchat_client/channel'
require 'backchat_client/stream'
require 'backchat_client/user'
require 'backchat_client/backchat_logger'
require 'addressable/uri'

module Backchat

  include BackchatClient::BackchatLogger

  #
  # This class is the main entry point to use the backchat-client gem.
  # It creates a client with a specific api_key that connects to Backchat
  # and processes any request.
  #
  class Client
    include BackchatClient::BackchatLogger

    # default endpoint where Backchat is deployed
    DEFAULT_ENDPOINT = "https://api.backchat.io/1"

    attr_accessor :api_key
    attr_reader :endpoint

    #
    # @param *api_key* application identifier
    # @param *endpoint* Backchat endpoint
    #
    def initialize(api_key, endpoint = nil)
      @api_key = api_key
      @endpoint = endpoint.nil? ? DEFAULT_ENDPOINT : endpoint
    end

    #
    # Checks if a Token is valid
    # @return true|false
    #
    def valid?
      !get_profile.nil?
    end

    #
    # *User management*

    #
    # get user profile.
    # The api_key used should be associated to a user
    # @return user profile or nil if invalid api_key
    #
    def get_profile
      user.find
    end

    #
    # Delete user account
    #
    def delete_user
      user.destroy
    end

    # *Channels management*

    #
    # Retrieves a specific channel or all the channels associated to the api_key
    # @return one or more channel data
    #
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

    #
    # Creates a specific channel
    # @param uri Full URI of the channel: <type>://<address>
    # @param bql optional backchat filter
    #
    def create_channel(uri, bql=nil)
      _channel = channel.create(generate_channel_url(uri, bql))

      if _channel.respond_to?("has_key?") and _channel.has_key?("data")
        _channel["data"]
      else
        logger.error("Invalid data received while creating channel #{_channel}")
        raise "No data received from Backchat while creating channel"
      end
    end

    #
    # Delete a channel
    # @param *name*
    # @param *force* true|false if channel should be deleted even if being used in a stream
    #
    def destroy_channel(name, force = false)
      channel.destroy(name, force)
    end

    # Streams management


    #
    # Retrieves a specific stream
    # @param *name* (optional) stream name. If undefined, all the user streams are retrieved
    # @return stream data hash
    #
    def find_stream(name = nil)
      streams = stream.find(name)

      if !streams.nil? and streams.respond_to?("has_key?") and streams.has_key?("data")
        streams["data"]
      else
        logger.debug "Stream with name #{name} not found in backchat"
        nil
      end
    end

    #
    # Create a specific stream
    # @param *name* unique stream identifier
    # @param *description* (optional)
    # @param *filters* (optional) array of filters
    #
    def create_stream(name, description = nil, filters = [])
      description.nil? and description = "Stream created using backchat-client gem"
      _stream = stream.create(name, description, filters)

      if _stream.respond_to?("has_key?") and _stream.has_key?("data")
        _stream["data"]
      else
        logger.error("Invalid data received while creating stream: #{_stream}")
        raise "No data received from Backchat while creating stream"
      end
    end

    #
    # This method updates the stream, assigning the new channels array to it.
    # In order to simplify, all the channels received will be automatically enabled.
    # @param *stream_slug* stream name
    # @param *channels* array of channels to be included in the stream
    # @param *reset* the channels are added (false) to the current channels or remove (true) the previous ones
    # @param *filter* valid Lucene syntax to filter the channels
    # @return *boolean* true if the stream was successfully updated, false in case of failure
    #
    def set_channels(stream_slug, channels = [], reset = false, filter = nil)
      st = stream.find(stream_slug) or raise "stream does not exist"

      st = st["data"]
      # format the channels array
      channels.map { |channel|
        channel[:enabled] = true
        channel[:channel]+="?q=#{filter}" unless filter.nil?
        channel[:channel] = Addressable::URI.parse(channel[:channel]).normalize.to_s
      }

      if reset
        # reset the stream channels
        st["channel_filters"] = channels
      else
        # add the new channels to the existing ones
        st["channel_filters"] |= channels
      end

      begin
        logger.debug("Updating stream channels to #{st}")
        stream.update(stream_slug, st)
        true
      rescue Exception => ex
        logger.error("Error while updating stream channels : #{ex.message}")
        logger.error(ex)
        false
      end

    end

    #
    # Delete a stream
    #
    def destroy_stream(name)
      stream.destroy(name)
    end

    #
    # Helper that generates the channel url using Addressable help
    #
    def generate_channel_url(channel_uri, filter = nil)
      if filter
        channel_uri += "?q=#{filter}"
      end
      Addressable::URI.parse(channel_uri).normalize.to_s
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
