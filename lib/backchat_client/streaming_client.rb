require 'backchat_client/http_client'
require 'backchat_client/backchat_logger'
require 'active_support'
require 'active_support/core_ext'
require 'web_socket'

module BackchatClient
  class Streaming

    include BackchatClient::BackchatLogger

    attr_reader :url

    def initialize(url, api_key, current_user = nil)
      # @current_user = 
      @api_key = api_key
      @url = url.gsub(/^http/i, 'ws')
      @subscriptions = {}
      @listener = nil
      connect
    end


    def authenticated?
      !!@authenticated
    end

    ##
    # Subscribe to a stream
    #
    # @param stream the slug of the stream to subscribe to
    # @param user the stream owner nickname
    # @param include_log_events include the log events in the stream, defaults to false
    # @param callback A block that takes a single parameter as callback for a new message.
    #
    def subscribe(stream, user = "casualjim", include_log_events = false, &callback)
      raise BackchatClient::Error::StreamingError.new("Stream name required") if stream.blank?
      raise BackchatClient::Error::StreamingError.new("Stream name required") if stream.blank?
      stream_id = "#{user}-#{stream}"
      start_listening unless @listener
      @subscriptions[stream_id] = callback
      write(["subscribe", user, stream])
    end


    ##
    # Unsubscribe from a stream
    #
    # @param stream the slug of the stream to subscribe to
    # @param user the stream owner nickname
    #
    def unsubscribe(stream, user = "casualjim")
      raise BackchatClient::Error::StreamingError.new("Stream name required") if stream.blank?
      stream_id = "#{user}-#{stream}"
      write ["unsubscribe", user, stream]
      !!@subscriptions.delete(stream_id)
    end

    def connect
      unless @authenticated
        @client = WebSocket.new(@url)
        authenticate
      end
    end

    def disconnect
      begin
        @listener.exit if @listener
        @listener = nil
      rescue 
      end
      @authenticated = false
      @subscriptions = {}
      @client.close()
    end

    private 
      def write(obj)
        @client.send(ActiveSupport::JSON.encode(obj))
      end


      def authenticate
        unless @authenticated
          logger.debug "authenticating"
          write ["auth", @api_key]
          ar = begin
            @client.receive
          rescue e
            logger.error(e)
            raise BackchatClient::Error::StreamingError, "Problem communicating with the BackChat.IO server."
          end
          if ar.blank?
            logger.error("Received bad reply from the server.")
            raise BackchatClient::Error::StreamingError, "Received bad reply from the server."
          else
            auth_response = ActiveSupport::JSON.decode(ar)
            if auth_response[0].chomp.downcase == "auth_success"
              logger.debug "Authenticated with backchat"
              @authenticated = true
            else
              logger.error("Invalid api key")
              raise BackchatClient::Error::StreamingError, "Invalid api key"
            end
          end
        end
      end

     

      def start_listening
        @listener = Thread.new do 
          while @authenticated
            puts "polling socket"
            data = @client.receive
            puts("data? #{data}")
            unless data.chomp.blank?
              begin
                json = ActiveSupport::JSON.decode(data)
                evt_name = json[0].chomp
                puts "event name: #{evt_name}"
                case evt_name
                when "log_event"
                  evt_data = json[1]
                  puts "event data: #{evt_data}"
                  sid = evt_data['stream_id']
                  puts "stream_id: #{sid}"
                  callback = @subscriptions[sid]
                  puts "callback: #{callback}"
                  callback.call(evt_data) if include_log_events
                when "new_message"
                  evt_data = json[1]
                  puts "event data: #{evt_data}"
                  sid = evt_data['stream_id']
                  puts "stream_id: #{sid}"
                  callback = @subscriptions[sid]
                  puts "callback: #{callback}"
                  callback.call(evt_data) 
                when "auth"
                  t.exit
                else
                  puts "ignoring #{evt_name}"
                end
              rescue e
                #logger.error(e)
                puts e
              end
            end
          end
        end
      end
  end
end