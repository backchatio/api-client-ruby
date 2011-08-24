require 'backchat-client'
require 'spec_helper'
require 'webmock/rspec'

describe BackchatClient::Stream do

  describe "when working with find method" do

    it "gets all the user defined streams when no name is provided" do
      pending
    end

    it "gets a specific stream when name is provided" do
      pending
    end

  end

  describe "when creating a stream" do
    it "returns the stream identifier" do
      pending
      bc = Backchat::Client.new(API_KEY)
      puts bc.create_stream("stream-name", nil, [{:channel => "twitter://juandebravo/#timeline", :enabled => true}])
    end
  end

  describe "when deleting a stream" do
    it "returns ok when the stream exists" do
      pending
      bc = Backchat::Client.new(API_KEY)
      puts bc.destroy_stream("stream-name")
    end
  end
end
