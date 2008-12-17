# TODO: Later on we should only require the loggers that are requested
Dir[File.join(File.dirname(__FILE__), "logging_adapters/*.rb")].each do |file|
  require file
end

module RosettaQueue
  class LoggingAdapter

    class << self
      
      def define
        yield self
      end

      def type=(logger_prefix)
        @log_adapter_class = "RosettaQueue::Logger::#{logger_prefix.to_s.classify}Adapter".constantize
        rescue NameError
          raise AdapterException, "Logging adapter type '#{logger_prefix}' does not match existing adapters!"
      end

      def instance
        raise AdapterException, "Logging adapter type was never defined!" unless @log_adapter_class
        @adapter_class.new
      end

    end
  end  
end