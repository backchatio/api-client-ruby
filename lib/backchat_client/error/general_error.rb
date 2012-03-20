module BackchatClient::Error

  class GeneralError < StandardError
    attr_reader :response

    def initialize(response = nil)
      if response.is_a?(String)
        @response = Struct.new(:body).new("{errors:[{\"general\":#{response}}]}")
      else
        @response = response
      end
    end
    
    def to_s
      errors.to_s
    end
    
    def errors
      @errors||=(
        errors = response
        if !response.nil? and response.respond_to?(:body)
          data = ActiveSupport::JSON.decode(response.body)
          data.respond_to?(:has_key?) and data.has_key?("errors") and errors = data["errors"].flatten
        end
        errors
      )
    end
  end

end