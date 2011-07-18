require 'backchat-client'

describe BackchatClient::Channel do
  API_KEY = "valid-api-key"

  describe "when working with find method" do

    it "gets all the user defined channels when no name is provided" do
      bc = Backchat::Client.new(API_KEY)
      puts bc.find_channel
    end

  end
  
  describe "when creating a channel" do
    it "returns the channel identifier" do
      bc = Backchat::Client.new(API_KEY)
      puts bc.create_channel("twitter", "juan")
    end
  end
  
  describe "when deleting a channel" do
    it "returns ok when the channel exists" do
      bc = Backchat::Client.new(API_KEY)
      puts bc.destroy_channel("twitter://connfudev/#timeline")
    end
  end

end