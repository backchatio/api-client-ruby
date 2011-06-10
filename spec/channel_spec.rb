require 'backchat-client'

describe BackchatClient::Channel do
  API_KEY = "5ed939eab9fdbaa631bf16fcc25fd1eb"

  describe "when working with find method" do

    it "gets all the user defined channels when no name is provided" do
      bc = Backchat::Client.new("5ed939eab9fdbaa631bf16fcc25fd1eb")
      puts bc.find_channel
    end

  end
  
  describe "when creating a channel" do
    it "returns the channel identifier" do
      bc = Backchat::Client.new("5ed939eab9fdbaa631bf16fcc25fd1eb")
      puts bc.create_channel("twitter", "rafeca")
    end
  end

end