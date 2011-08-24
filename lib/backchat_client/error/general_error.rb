module BackchatClient::Error

    class GeneralError < StandardError
      attr_reader :response

      def initialize(response = nil)
        @response = response
      end
      
      def to_s
        response
      end
      
      def errors
        @errors||=(
          errors = nil
          if !response.nil? and response.respond_to?(:body)
            data = ActiveSupport::JSON.decode(response.body)
            data.has_key?("errors") and errors = data["errors"].flatten
          end
          errors
        )
          
      end
    end

end