require 'backchat_client/channel'
require 'backchat_client/stream'
require 'backchat_client/user'
require 'backchat_client/backchat_logger'
require 'addressable/uri'

module Backchat
  class Client
    include BackchatClient::BackchatLogger

    DEFAULT_ENDPOINT = "https://api.backchat.io/1"

    attr_accessor :api_key
    attr_reader :endpoint
    
    def initialize(api_key, endpoint = nil)
      @api_key = api_key
      @endpoint = endpoint.nil? ? DEFAULT_ENDPOINT : endpoint
    end
    
    #
    # Checks if a Token is valid
    #
    def valid?
      !get_profile.nil?
    end
    
    # User management
    
    #
    # get user profile
    #
    def get_profile
      user.find
    end
    
    def delete_user
      user.destroy
    end
    
    # Channels management
    
    def find_channel(name = nil)
      channels = channel.find(name)

      if channels.respond_to?("has_key?") and channels.has_key?("data")
        channels["data"]
      end
    end
    
    def create_channel(channel_type, id, bql=nil)
      _channel = channel.create(generate_channel_url(channel_type,id,bql))
        
      if _channel.respond_to?("has_key?") and _channel.has_key?("data")
        _channel["data"]["uri"]
      end
    end
    
    def destroy_channel(name, force = false)
      channel.destroy(name, force)
    end
    
    # Streams management
    
    def find_stream(name = nil)
      streams = stream.find(name)

      if streams.respond_to?("has_key?") and streams.has_key?("data")
        streams["data"]
      end
    end
    
    def create_stream(name, description = nil, filters = [])
      description.nil? and description = "Stream created using Backchat client gem"
      _stream = stream.create(name, description, filters)

      if _stream.respond_to?("has_key?") and _stream.has_key?("data")
        _stream["data"]["uri"]
      end
    end
    
    # This method updates the stream, assigning the new channels array to it.
    # In order to simplify, all the channels sent by parameters will be enabled.
    # @return true if the stream was successfully updated
    # @raise exception if stream is not found
    def set_channels(stream_slug, channels = [], reset = false, bql = nil)
      st = stream.find(stream_slug) or raise "stream does not exist"
      st = st["data"]
      channels.map{|c| 
        c[:enabled] = true 
        c[:channel]+="?bql=#{bql}" unless bql.nil? 
        c[:channel] = Addressable::URI.parse(c[:channel]).normalize.to_s 
      }
      if reset
        st["channel_filters"] = channels
      else
        st["channel_filters"] |= channels
      end
      stream.update(stream_slug, st)
      true
    end
    
    def generate_channel_url(type, id, bql = nil)
      channel_uri = "#{type}://#{id}"
      if bql
        channel_uri += "?bql=#{bql}"
      end
      Addressable::URI.parse(channel_uri).normalize.to_s
    end
    
    def destroy_stream(name)
      stream.destroy(name)
    end
    
    private
    
    def user
      @user ||= BackchatClient::User.new(api_key, endpoint.dup)
    end
    
    def channel
      @channel ||= BackchatClient::Channel.new(api_key, endpoint.dup)
    end
    
    def stream
      @stream ||= BackchatClient::Stream.new(api_key, endpoint.dup)
    end
    
  end
end
