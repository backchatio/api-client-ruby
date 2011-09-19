$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')
$:.unshift File.join(File.dirname(__FILE__), '.')

require 'backchat-client'
require 'setup'

ARGV.length < 2 and
(
  puts "Please include as argument the api_key, the stream and the channel to be used"
  exit
)

api_key = ARGV.shift

stream = if ARGV.length < 3
             ""
         else
             ARGV.shift
         end
         
channel = ARGV.shift

Backchat::Client.log_level=Logger::DEBUG
bc = Backchat::Client.new(api_key, BACKCHAT_ENDPOINT)

begin
  puts bc.delete_channel_from_stream(channel, stream)
  
rescue Exception => ex
  puts ex.message
  puts ex
end


