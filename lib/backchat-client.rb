require 'backchat_client/channel'
require 'backchat_client/stream'
require 'backchat_client/user'

module Backchat
  class Client

    DEFAULT_ENDPOINT = "https://api.backchat.io/1"

    attr_accessor :api_key
    attr_reader :endpoint
    
    def initialize(api_key, endpoint = nil)
      @api_key = api_key
      @endpoint = endpoint.nil? ? DEFAULT_ENDPOINT : endpoint
    end
    
    # User management
    
    def get_profile
      user.find
    end
    
    # Channels management
    
    def find_channel(name = nil)
      channels = channel.find(name)

      if channels.respond_to?("has_key?") and channels.has_key?("data")
        channels["data"]
      end
    end
    
    def create_channel(channel_type, id)
      _channel = channel.create("#{channel_type}://#{id}")
      
      if _channel.respond_to?("has_key?") and _channel.has_key?("data")
        _channel["data"]["uri"]
      end
    end
    
    def destroy_channel(name)
      channel.destroy(name)
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
