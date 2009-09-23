module RosettaQueue
  module MessageHandler

    module ClassMethods

      attr_reader :destination, :options_hash

      def options(options = {})
        @options_hash = options
      end

      def publishes_to(destination)
        @destination = destination
      end

      def subscribes_to(destination)
        @destination = destination
      end
    end

    def self.included(receiver)
      receiver.extend(ClassMethods)
      attr_accessor :adapter_proxy

      def destination
        self.class.destination
      end

      def options_hash
        self.class.options_hash
      end

      def ack
        adapter_proxy.ack unless adapter_proxy.nil?
      end

    end
  end
end
