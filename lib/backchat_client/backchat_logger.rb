require 'logger'

module BackchatClient

  #
  # This module injects methods to handle log mechanism
  #
  module BackchatLogger
    #
    # Nice way to include the Module methods when including it in a class/module
    #
    def self.included(base)
      base.extend(ClassMethods)
    end

    #
    # This module acts as a wrapper to include the class/module level methods
    #
    module ClassMethods

      # logger setter
      # @param value should be a valid IO object (STDOUT, string representing a valid filename, File object)
      # @return new Logger object created
      def logger=(value)
        # _logger must be static var and not class var to be shared between objects/classes
        if value.is_a?(String)
          @@_logger = Logger.new(value)
        else
          @@_logger = value
        end
      end

      # logger getter
      # @return Logger object
      def logger
        @@_logger ||= create_logger
      end

      # change logger level
      # @param level valid    Logger level constant (Logger::DEBUG, etc)
      def log_level=(level)
        logger.level = level
      end

      #
      # Creates a new Logger object and defines the level and format
      #
      def create_logger(output = nil)
        output.nil? and output = STDOUT
        logger = Logger.new(output)
        logger.level = Logger::ERROR
        #logger.formatter = proc { |severity, datetime, progname, msg|
        #  "#{severity} on #{datetime} at #{progname}: #{msg}\n"
        #}
        logger.datetime_format = "%Y-%m-%d %H:%M:%S"
        logger
      end
    end

    def logger
      self.class.logger
    end

    # debug message with the class name a the beginning of the log
    def debug(message)
      logger.debug "#{self.class} #{message}"
    end

    # error message with the class name a the beginning of the log
    def error(message)
      logger.error "#{self.class} #{message}"
    end

  end
end
