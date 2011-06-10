This is a light library to access the Backchat provisioning API

# Getting started

You need a valid api-key to access Backchat API

    require 'backchat-client'
	bc = Backchat::Client.new("api-key")
	
# Streams

## Create a new stream
    require 'backchat-client'
    bc = Backchat::Client.new("api-key")
    bc.create_stream("conference-application", "This is the stream for my conference app")

## Retrieve application streams
    require 'backchat-client'
    bc = Backchat::Client.new("api-key")
    streams = bc.find_stream

## Delete a stream
    require 'backchat-client'
    bc = Backchat::Client.new("api-key")
    bc.destroy_stream("conference-application")

# Channels

## Create a new channel
    require 'backchat-client'
    bc = Backchat::Client.new("api-key")
    bc.create_channel("twitter", "rafeca")
