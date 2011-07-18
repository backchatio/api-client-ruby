require 'backchat-client'
require 'webmock/rspec'

describe BackchatClient::User do
  
  before(:each) do
    Backchat::Client.log_level = Logger::DEBUG
  end

  describe "when working with find method" do

    it "gets all the user defined streams when no name is provided" do
      api_key = "5ed939eab9fdbaa631bf16fcc25fd1eb"
      bc = Backchat::Client.new(api_key)
      stub_request(:get, "https://api.backchat.io/1/index.json?").
                with(:headers => {'Accept'=>'application/json', 'Authorization' => "Backchat #{api_key}"}).
                to_return(:status => 200, :body => "{'data':{'channels':[{'uri':'smtp://user.channel/'}, {'uri':'twitter://username'}],'email':'user@backchat.com','_id':'user_id','api_key':'#{api_key}','last_name':'lastname','first_name':'name','plan':'https://api.backchat.io/1/plans/free','streams':['https://api.backchat.io/1/streams/user-stream'],'login':'user'},'errors':[]}", :headers => {})

      profile = bc.get_profile
      ["channels", "email", "api_key"].each{|key|
        profile.should have_key(key)
      }
    end
  
  end

end