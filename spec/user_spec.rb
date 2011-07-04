require 'backchat-client'

describe BackchatClient::Stream do
  API_KEY = "5ed939eab9fdbaa631bf16fcc25fd1eb"

  describe "when working with find method" do

    it "gets all the user defined streams when no name is provided" do
      bc = Backchat::Client.new("5ed939eab9fdbaa631bf16fcc25fd1eb")
      puts bc.get_profile
    end
  
  end
  
end