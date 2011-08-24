require 'backchat-client'
require 'spec_helper'
require 'webmock/rspec'

describe BackchatClient::User do
  
  describe "when working with find method" do

    it "gets all the user defined streams when no name is provided" do
      bc = Backchat::Client.new(API_KEY)
      stub_request(:get, "https://api.backchat.io/1/index.json?").
                with(:headers => {'Accept'=>'application/json', 'Authorization' => "Backchat #{API_KEY}"}).
                to_return(:status => 200, :body => "{'data':{'channels':[{'uri':'smtp://user.channel/'}, {'uri':'twitter://username'}],'email':'user@backchat.com','_id':'user_id','api_key':'#{API_KEY}','last_name':'lastname','first_name':'name','plan':'https://api.backchat.io/1/plans/free','streams':['https://api.backchat.io/1/streams/user-stream'],'login':'user'},'errors':[]}", :headers => {})

      profile = bc.get_profile
      ["channels", "email", "api_key"].each{|key|
        profile.should have_key(key)
      }
    end
  
    it "deletes a user when valid api_key provided" do
      bc = Backchat::Client.new(API_KEY)
      stub_request(:delete, "https://api.backchat.io/1/?").
                with(:headers => {'Accept'=>'application/json', 'Authorization' => "Backchat #{API_KEY}"}).
                to_return(:status => 200, :body => "", :headers => {})

      result = bc.delete_user
      result.should eql("")
    end

  end

end