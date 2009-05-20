require 'rosetta_queue/adapters/base'

module RosettaQueue
  class Adapter

    class << self
      attr_writer :user, :password, :host, :port, :options
      
      def define
        yield self
      end
            
      def reset
        @user, @password, @host, @port, @options, @adapter_class = nil, nil, nil, nil, nil, nil
      end
      
      def type=(adapter_prefix)
        require "rosetta_queue/adapters/amqp_base" if adapter_prefix =~ /amqp/
        require "rosetta_queue/adapters/#{adapter_prefix}"
        @adapter_class = RosettaQueue::Gateway.const_get("#{adapter_prefix.to_s.classify}Adapter")

        rescue MissingSourceFile
          raise AdapterException, "Adapter type '#{adapter_prefix}' does not match existing adapters!"
      end

      def instance
        raise AdapterException, "Adapter type was never defined!" unless @adapter_class
        @adapter_class.new({:user => @user, :password => @password, :host => @host, :port => @port, :opts => opts})
      end

      private
      
      def opts
        raise AdapterException, "Adapter options should be a hash" unless @options.nil? || @options.is_a?(Hash)
        @options ||= {}
      end
      
    end
  end  
end
