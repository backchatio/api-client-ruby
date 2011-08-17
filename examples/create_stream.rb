$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')
$:.unshift File.join(File.dirname(__FILE__), '.')

require 'backchat-client'
require 'setup'

ARGV.length < 2 and
(
  puts "Please include as argument the api_key and stream_name to be used"
  exit
)

api_key = ARGV.shift

stream = ARGV.shift

bc = Backchat::Client.new(api_key, BACKCHAT_ENDPOINT)
bc.logger.level = Logger::DEBUG

puts bc.create_stream(stream)
