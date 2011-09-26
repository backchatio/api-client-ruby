module BackchatClient::Error

    class ClientError < GeneralError

    end
    
    class ConflictError < ClientError

    end
    
    class NotFoundError < ClientError

    end
    
    class UnprocessableError < ClientError
    end

end