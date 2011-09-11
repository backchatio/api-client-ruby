require 'rest_client'
require 'cgi'
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
    
    # This method is used to handle the HTTP response
    # *response* HTTP response
    # *request* HTTP request
    # *result*
    def response_handler(response, request, result, &block)
      case response.code
      when 200..207
        # If there is a :location header, return it
        response.return!(request, result, &block)
      when 301..307
        response.follow_redirection(request, result, &block)
      when 400
        logger.warn("Bad request")
        logger.warn("#{result.code} => #{result.message}")
        raise BackchatClient::Error::ClientError.new(result)
      when 401
        logger.warn("Error while accessing Backchat. Authentication failed")
        logger.warn("#{result.code} => #{result.message}")
        raise BackchatClient::Error::ClientError.new(result)
      when 404
        logger.warn("Error while accessing Backchat. Resource not found")
        logger.warn("#{result.code} => #{result.message}")
        raise BackchatClient::Error::ClientError.new(result)
      when 409
        logger.warn("Error while accessing Backchat. Conflict")
        logger.warn("#{result.code} => #{result.message}")
        raise BackchatClient::Error::ConflictError.new(result)
      when 422
        logger.warn("Error while accessing Backchat. Unprocessable entity")
        logger.warn("#{result.code} => #{result.message}")
        raise BackchatClient::Error::UnprocessableError.new(result)
      when 402..408,410..421,423..499
        logger.warn("Error while accessing Backchat")
        logger.warn("#{result.code} => #{result.message}")
        response.return!(request, result, &block)
      when 500..599
        logger.warn("Error while accessing Backchat")
        logger.warn("#{result.code} => #{result.message}")
        raise BackchatClient::Error::ServerError.new(result)
      else
        logger.warn("Error while accessing Backchat")
        logger.warn("#{result.code} => #{result.message}")
        response.return!(request, result, &block)
      end
    end

    # HTTP GET
    def get(path, params = {}, headers = {})
      headers.merge!({:Authorization => "Backchat #{@api_key}", :Accept => "application/json"})

      uri = set_path(path)
      uri = "#{uri}?".concat(params.collect { |k, v| "#{k}=#{CGI::escape(v.to_s)}" }.join("&"))
      debug("get request to uri #{uri}")
      RestClient.get(uri, headers) { |response, request, result, &block|
        response_handler(response, request, result, &block)
      }
      
      
    end

    # HTTP POST
    def post(path, body = {}, headers = {})
      headers.merge!({:Authorization => "Backchat #{@api_key}", :content_type => :json, :accept => :json})
      body = ActiveSupport::JSON.encode(body)
      uri = set_path(path)
      debug("post request to uri #{uri}")
      debug("post body: <#{body}>")
      RestClient.post("#{uri}", body, headers) { |response, request, result, &block|
        response_handler(response, request, result, &block)
      }
    end

    # HTTP PUT
    def put(path, body = {}, headers = {})
      headers.merge!({:Authorization => "Backchat #{@api_key}", :content_type => :json, :accept => :json})
      body = ActiveSupport::JSON.encode(body)
      uri = set_path(path)
      debug("put request to uri #{uri}")
      debug("put body: <#{body}>")
      RestClient.put("#{uri}", body, headers) { |response, request, result, &block|
        response_handler(response, request, result, &block)
      }
    end

    # HTTP DELETE
    def delete(path, params = {}, headers = {})
      headers.merge!({:Authorization => "Backchat #{@api_key}", :accept => :json})
      uri = set_path(path)
      uri = "#{uri}?".concat(params.collect { |k, v| "#{k}=#{CGI::escape(v.to_s)}" }.join("&"))
      debug("delete request to uri #{uri}")
      RestClient.delete(uri, headers) { |response, request, result, &block|
        response_handler(response, request, result, &block)
      }
    end

    private

    def set_path(path)
      if uri_path.nil?
        "#{@endpoint}/#{CGI::escape(path)}"
      else
        "#{@endpoint}/#{uri_path}/#{CGI::escape(path)}"
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