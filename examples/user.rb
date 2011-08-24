$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')
$:.unshift File.join(File.dirname(__FILE__), '.')

require 'backchat-client'
require 'setup'

ARGV.length < 1 and
(
  puts "Please include as argument the api_key to be used"
  exit
)

api_key = ARGV.shift


Backchat::Client.log_level = Logger::DEBUG
bc = Backchat::Client.new(api_key, BACKCHAT_ENDPOINT)
puts bc.get_profile

