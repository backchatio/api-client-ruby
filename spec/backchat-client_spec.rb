require 'backchat-client'
require 'spec_helper'
require 'webmock/rspec'

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
        stub_request(:get, "https://api.backchat.io/1/index.json?").
                  with(:headers => {'Accept'=>'application/json', 'Authorization' => "Backchat #{API_KEY}"}).
                  to_return(:status => 200, :body => "{'data':{'channels':[],'email':'user@backchat.com','_id':'user_id','api_key':'#{API_KEY}','last_name':'lastname','first_name':'name','plan':'https://api.backchat.io/1/plans/free','streams':[],'login':'user'},'errors':[]}", :headers => {})

        bc = Backchat::Client.new(API_KEY)
        bc.valid?.should eql(true)
      end

      it "returns false with a valid token" do
        stub_request(:get, "https://api.backchat.io/1/index.json?").
                  with(:headers => {'Accept'=>'application/json', 'Authorization' => "Backchat #{INVALID_API_KEY}"}).
                  to_return(:status => 401, :body => "{'data':null,'errors':[['','Unauthorized']]}", :headers => {})

        bc = Backchat::Client.new(INVALID_API_KEY)
        bc.valid?.should eql(false)
      end
    end

    

  end

end