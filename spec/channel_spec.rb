require 'backchat-client'
require 'spec_helper'
require 'webmock/rspec'

describe BackchatClient::Channel do

  describe "when working with find method" do

    it "gets all the user defined channels" do
      stub_request(:get, "https://api.backchat.io/1/channels/index.json?").
          with(:headers => {'Accept'=>'application/json', 'Authorization' => "Backchat #{API_KEY}"}).
          to_return(:body => '{"data":[{"uri":"twitter://pastoret/#timeline"},{"uri":"twitter://juandebravo/#timeline"}],"errors":[]}')

      bc = Backchat::Client.new(API_KEY)
      channels = bc.find_channel
      channels.should be_a(Array)
      channels.length.should eql(2)
      channels.each { |channel|
        channel.should be_a(Hash)
        channel.should have_key("uri")
      }
    end

  end

  describe "when creating a channel" do
    it "returns the channel identifier" do
      stub_request(:post, "https://api.backchat.io/1/channels/index.json").
          with(:body => '{"channel":"twitter://juandebravo"}', :headers => {'Accept'=>'application/json', 'Authorization' => "Backchat #{API_KEY}"}).
          to_return(:body => '{"data":{"uri":"twitter://juandebravo/#timeline"}, "errors":[]}')

      bc = Backchat::Client.new(API_KEY)

      channel = bc.create_channel("twitter://juandebravo")
      channel.should be_a(Hash)
      channel.should have_key("uri")
      channel["uri"].should eql("twitter://juandebravo/#timeline")
    end
  end

  describe "when deleting a channel" do
    it "returns ok when the channel exists and force is set to false" do
      stub_request(:delete, "https://api.backchat.io/1/channels/?channel=twitter://juandebravo/&force=false").
          with(:headers => {'Accept'=>'application/json', 'Authorization' => "Backchat #{API_KEY}"}).
          to_return(:body => '{"data":{}, "errors":[]}')

      bc = Backchat::Client.new(API_KEY)
      result = bc.destroy_channel("twitter://juandebravo/")
      result.should eql(true)
    end

    it "returns ok when the channel exists and force is set to true" do
      stub_request(:delete, "https://api.backchat.io/1/channels/?channel=twitter://juandebravo/&force=true").
          with(:query => {"channel" => "twitter://juandebravo/", "force" => "true"}, :headers => {'Accept'=>'application/json', 'Authorization' => "Backchat #{API_KEY}"}).
          to_return(:body => '{"data":{}, "errors":[]}')

      bc = Backchat::Client.new(API_KEY)
      result = bc.destroy_channel("twitter://juandebravo/", true)
      result.should eql(true)
    end


  end

end