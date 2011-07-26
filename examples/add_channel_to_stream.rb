$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'backchat-client'

ARGV.length < 3 and
(
  puts "Please include as argument the api_key, the origin stream slug and the new channel to be used"
  exit
)

api_key = ARGV.shift
stream_slug = ARGV.shift
channel = ARGV.shift

bc = Backchat::Client.new(api_key)
bc.logger.level = Logger::DEBUG

begin
  puts bc.set_channels(stream_slug, [{:channel  => channel}])
rescue Exception => ex
  puts ex
  puts ex.inspect
end
