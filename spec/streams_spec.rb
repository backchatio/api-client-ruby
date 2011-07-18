require 'backchat-client'

describe BackchatClient::Stream do
  API_KEY = "valid_api_key"

  before(:each) do
    Backchat::Client.log_level = Logger::DEBUG
  end

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
      puts bc.create_stream("stream-name", nil, [{:channel => "twitter://connfudev/#timeline", :enabled => true}])
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
