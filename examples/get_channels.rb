$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'backchat-client'

ARGV.length < 1 and
(
  puts "Please include as argument the api_key"
  exit
)

api_key = ARGV.shift

bc = Backchat::Client.new(api_key)
bc.logger.level=Logger::DEBUG

begin
  puts bc.find_channel
rescue Exception => ex
  puts ex.message
  puts ex
end

