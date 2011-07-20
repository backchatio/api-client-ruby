$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'backchat-client'

ARGV.length < 2 and
(
  puts "Please include as argument the api_key, channel_name to be used"
  exit
)

api_key = ARGV.shift

channel = ARGV.shift

bc = Backchat::Client.new(api_key)
bc.logger.level = Logger::DEBUG

puts bc.destroy_channel(channel, true)
