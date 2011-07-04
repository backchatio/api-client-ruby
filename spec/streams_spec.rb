require 'backchat-client'

describe BackchatClient::Stream do
  API_KEY = "5ed939eab9fdbaa631bf16fcc25fd1eb"

  describe "when working with find method" do

    it "gets all the user defined streams when no name is provided" do
      bc = Backchat::Client.new("5ed939eab9fdbaa631bf16fcc25fd1eb")
      puts bc.find_stream
    end

  end

  describe "when creating a stream" do
    it "returns the stream identifier" do
      bc = Backchat::Client.new("5ed939eab9fdbaa631bf16fcc25fd1eb")
      # channel = bc.create_channel("twitter", "connfudev")
      # puts channel
      puts bc.create_stream("juan-test4", nil, [{:channel => "twitter://connfudev/#timeline", :enabled => true}])
    end
  end

  describe "when deleting a stream" do
    it "returns ok when the stream exists" do
      bc = Backchat::Client.new("5ed939eab9fdbaa631bf16fcc25fd1eb")
      puts bc.destroy_stream("juan-test4")
    end
  end
end