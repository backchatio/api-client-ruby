$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')
$:.unshift File.join(File.dirname(__FILE__), '.')

require 'backchat-client'
require 'setup'

ARGV.length < 2 and
(
  puts "Please include as argument the api_key, channel_type and channel_name to be used"
  exit
)

api_key = ARGV.shift

type = ARGV.shift

name = ARGV.shift

bc = Backchat::Client.new(api_key, BACKCHAT_ENDPOINT)
bc.logger.level = Logger::DEBUG

begin
  puts bc.create_channel(type, name)
rescue BackchatClient::Error::ConflictError => ex
  puts "channel already exists"
rescue BackchatClient::Error::UnprocessableError => ex
  puts "invalid channel name"
  p ex.errors
end
