$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'backchat-client'

ARGV.length < 1 and
(
  puts "Please include as argument the api_key to be used"
  exit
)

api_key = ARGV.shift

bc = Backchat::Client.new(api_key)

puts bc.find_stream

