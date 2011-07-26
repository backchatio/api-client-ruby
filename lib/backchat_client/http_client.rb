require 'rest_client'
require 'backchat_client/backchat_logger'

module BackchatClient
  #
  # This module sends HTTP requests to Backchat including the specific
  # header authenticating the sender
  # It's just a mixin, some features must be pre-loaded in the entity that uses
  # the mixin
  # @endpoint: Backchat API URI: https://api.backchat.io
  # @api_key: application api key: kljdfjrwerwlkdfjsldkf
  # URI_PATH: entity/model specific: streams, channels, etc.
  #
  module HttpClient

    include BackchatClient::BackchatLogger

    # HTTP GET
    def get(path, params = {}, headers = {})
      headers.merge!({:Authorization => "Backchat #{@api_key}", :Accept => "application/json"})

      uri = set_path(path)
      uri = "#{uri}?".concat(params.collect { |k, v| "#{k}=#{v.to_s}" }.join("&"))
      debug("get request to uri #{uri}")
      RestClient.get(uri, headers)
    end

    # HTTP POST
    def post(path, body = {}, headers = {})
      headers.merge!({:Authorization => "Backchat #{@api_key}", :content_type => :json, :accept => :json})
      body = ActiveSupport::JSON.encode(body)
      uri = set_path(path)
      debug("post request to uri #{uri}")
      debug("post body: <#{body}>")
      RestClient.post("#{uri}", body, headers)
    end

    # HTTP PUT
    def put(path, body = {}, headers = {})
      headers.merge!({:Authorization => "Backchat #{@api_key}", :content_type => :json, :accept => :json})
      body = ActiveSupport::JSON.encode(body)
      uri = set_path(path)
      debug("put request to uri #{uri}")
      debug("put body: <#{body}>")
      RestClient.put("#{uri}", body, headers)
    end

    # HTTP DELETE
    def delete(path, params = {}, headers = {})
      headers.merge!({:Authorization => "Backchat #{@api_key}", :accept => :json})
      uri = set_path(path)
      uri = "#{uri}?".concat(params.collect { |k, v| "#{k}=#{v.to_s}" }.join("&"))
      debug("delete request to uri #{uri}")
      RestClient.delete(uri, headers)
    end

    private

    def set_path(path)
      if uri_path.nil?
        "#{@endpoint}/#{path}"
      else
        "#{@endpoint}/#{uri_path}/#{path}"
      end
    end

    # Returns the entity URI_PATH constant (loaded from the entity class)
    def uri_path
      unless defined? self.class::URI_PATH
        raise RuntimeError.new "URI_PATH constant should be defined"
      end
      self.class::URI_PATH
    end

  end
end