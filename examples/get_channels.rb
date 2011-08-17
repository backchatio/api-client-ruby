$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')
$:.unshift File.join(File.dirname(__FILE__), '.')

require 'backchat-client'
require 'setup'

ARGV.length < 1 and
(
  puts "Please include as argument the api_key"
  exit
)

api_key = ARGV.shift

bc = Backchat::Client.new(api_key, BACKCHAT_ENDPOINT)
bc.logger.level=Logger::DEBUG

begin
  puts bc.find_channel
rescue Exception => ex
  puts ex.message
  puts ex
end

