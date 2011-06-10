require 'backchat-client'

describe Backchat::Client do

  describe "it initializes correctly the client" do

    it "gets the api key and the endpoint" do
      bc = Backchat::Client.new("api-key", "endpoint")
      bc.endpoint.should eq("endpoint")
      bc.api_key.should eq("api-key")
    end

    it "gets the api key and the default endpoint" do
      bc = Backchat::Client.new("api-key")
      bc.endpoint.should eq(Backchat::Client::DEFAULT_ENDPOINT)
      bc.api_key.should eq("api-key")
    end

  end

end