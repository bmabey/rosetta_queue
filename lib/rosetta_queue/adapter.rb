require 'rosetta_queue/adapters/base'

module RosettaQueue
  class Adapter

    class << self
      attr_writer :user, :password, :host, :port
      
      def define
        yield self
      end
      
      def reset
        @user, @password, @host, @port, @adapter_class = nil, nil, nil, nil, nil
      end
      
      def type=(adapter_prefix)
        begin
          require "rosetta_queue/adapters/#{adapter_prefix}"
        rescue LoadError
          raise AdapterException, "Adapter type '#{adapter_prefix}' does not match existing adapters!"
        end
        @adapter_class = RosettaQueue::Gateway.const_get("#{adapter_prefix.to_s.classify}Adapter")
      end

      def instance
        raise AdapterException, "Adapter type was never defined!" unless @adapter_class
        @adapter_class.new(@user, @password, @host, @port)
      end

    end
  end  
end
