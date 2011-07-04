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
    
    describe "valid? method" do
      it "returns true with a valid token" do
        bc = Backchat::Client.new("5ed939eab9fdbaa631bf16fcc25fd1eb")
        bc.valid?.should eql(true)
      end

      it "returns false with a valid token" do
        bc = Backchat::Client.new("5ed93")
        bc.valid?.should eql(false)
      end
    end

    

  end

end