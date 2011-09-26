require 'backchat-client'
require 'spec_helper'
require 'webmock/rspec'

describe Backchat::Client do
  
  # Matcher that helps to test if a BackchatClient:Error instance is well defined after retrieving data using prov API
  RSpec::Matchers.define :be_well_defined_error do |klass, expected|
    match do |value|
      value.should be_instance_of(klass)
      value.errors.should be_a(Array)
      value.errors.length.should eql(expected.length)
      value.errors.each{|error| error.should be_a(Hash)}
      
      expected.each_with_index{|e, index|
        e.each{|k,v|
          value.errors[index].should have_key(k)
          value.errors[index][k].should eql(v)
        }
      }
    end
  end
  
  RSpec::Matchers.define :be_well_defined_backchat_client do |api_key, endpoint|
    match do |value|
      value.api_key.should eql(api_key)
      value.endpoint.should eql(endpoint)
    end
  end
  
  describe "it initializes correctly the client" do

    it "gets the api key and the endpoint" do
      bc = Backchat::Client.new("api-key", "endpoint")
      bc.should be_well_defined_backchat_client("api-key", "endpoint")
    end

    it "gets the api key and the default endpoint" do
      bc = Backchat::Client.new("api-key")
      bc.should be_well_defined_backchat_client("api-key", Backchat::Client::DEFAULT_ENDPOINT)
    end
  end
    
  describe "valid? method" do
    it "returns true with a valid token" do
      stub_request(:get, "https://api.backchat.io/1/index.json?").
                with(:headers => {'Accept'=>'application/json', 'Authorization' => "Backchat #{API_KEY}"}).
                to_return(:status => 200, :body => "{'data':{'channels':[],'email':'user@backchat.com','_id':'user_id','api_key':'#{API_KEY}','last_name':'lastname','first_name':'name','plan':'https://api.backchat.io/1/plans/free','streams':[],'login':'user'},'errors':[]}", :headers => {})

      bc = Backchat::Client.new(API_KEY)
      bc.valid?.should eql(true)
    end

    it "checks with Backchat if the token is valid only the first time" do
      bc = Backchat::Client.new(API_KEY)
      bc.should_receive(:get_profile).once.and_return({})
      bc.valid?.should eql(true)
      bc.valid?.should eql(true)
    end

    it "checks with Backchat if the token is valid only the first time (II)" do
      bc = Backchat::Client.new(API_KEY)
      bc.should_receive(:get_profile).once.and_return(nil)
      bc.valid?.should eql(false)
      bc.valid?.should eql(false)
    end

    it "returns false with a valid token" do
      stub_request(:get, "https://api.backchat.io/1/index.json?").
                with(:headers => {'Accept'=>'application/json', 'Authorization' => "Backchat #{INVALID_API_KEY}"}).
                to_return(:status => 401, :body => "{'data':null,'errors':[['','Unauthorized']]}", :headers => {})

      bc = Backchat::Client.new(INVALID_API_KEY)
      bc.valid?.should eql(false)
    end
  end
  
  describe "while creating a Backchat channel" do
    it "returns valid data when name is provided" do
      stub_request(:post, "https://api.backchat.io/1/channels/index.json").
          with(:body => '{"channel":"twitter://juandebravo"}', :headers => {'Accept'=>'application/json', 'Authorization' => "Backchat #{API_KEY}"}).
          to_return(:body => '{"data":{"uri":"twitter://juandebravo/#timeline"}, "errors":[]}')

      bc = Backchat::Client.new(API_KEY)

      channel = bc.create_channel("twitter://juandebravo")
      channel.should be_a(Hash)
      channel.should have_key("uri")
      channel["uri"].should eql("twitter://juandebravo/#timeline")
    end

    it "returns valid data when name provided and filter are provided" do
      stub_request(:post, "https://api.backchat.io/1/channels/index.json").
          with(:body => '{"channel":"twitter://juandebravo?q=text(LONDON)"}', :headers => {'Accept'=>'application/json', 'Authorization' => "Backchat #{API_KEY}"}).
          to_return(:body => '{"data":{"uri":"twitter://juandebravo/#timeline"}, "errors":[]}')

      bc = Backchat::Client.new(API_KEY)

      channel = bc.create_channel("twitter://juandebravo", "text(LONDON)")
      channel.should be_a(Hash)
      channel.should have_key("uri")
      channel["uri"].should eql("twitter://juandebravo/#timeline")
    end

    it "returns a ClientError when Backchat returns a 400 error" do
      stub_request(:post, "https://api.backchat.io/1/channels/index.json").
          with(:body => '{"channel":"invalid-uri"}', :headers => {'Accept'=>'application/json', 'Authorization' => "Backchat #{API_KEY}"}).
          to_return(:status => 400, :body => '{"data":{}, "errors":[[{"uri":"Invalid channel URI"}]]}')

      bc = Backchat::Client.new(API_KEY)
      
      lambda { value = bc.create_channel("invalid-uri")}.should raise_error(BackchatClient::Error::ClientError) {|result|
        result.should be_well_defined_error(BackchatClient::Error::ClientError, [{"uri" => "Invalid channel URI"}])
      }
      
    end

    it "returns a ConflictError when Backchat returns a 409 error" do
      stub_request(:post, "https://api.backchat.io/1/channels/index.json").
          with(:body => '{"channel":"invalid-uri"}', :headers => {'Accept'=>'application/json', 'Authorization' => "Backchat #{API_KEY}"}).
          to_return(:status => 409, :body => '{"data":{}, "errors":[[{"uri":"Channel URI already exists"}]]}')

      bc = Backchat::Client.new(API_KEY)
      
      lambda { value = bc.create_channel("invalid-uri")}.should raise_error(BackchatClient::Error::ConflictError) {|result|
        result.should be_well_defined_error(BackchatClient::Error::ConflictError, [{"uri" => "Channel URI already exists"}])
      }
    end

    it "returns a GeneralError when Backchat returns no data" do
      stub_request(:post, "https://api.backchat.io/1/channels/index.json").
          with(:body => '{"channel":"invalid-uri"}', :headers => {'Accept'=>'application/json', 'Authorization' => "Backchat #{API_KEY}"}).
          to_return(:status => 200, :body => '{}')

      bc = Backchat::Client.new(API_KEY)
      
      lambda { value = bc.create_channel("invalid-uri")}.should raise_error(BackchatClient::Error::GeneralError) {|result|
        result.should be_well_defined_error(BackchatClient::Error::GeneralError, [{"general" => "No data received from Backchat while creating channel"}])
      }
    end
  end

end