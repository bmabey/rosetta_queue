module RosettaQueue
  module Gateway

    class Amqp < BaseAdapter

      def initialize(adapter_settings = {})
        raise AdapterException, "Missing adapter settings" if adapter_settings.empty?
        @adapter_settings = adapter_settings
      end

      def delete(destination, opts={})
        exchange_strategy_for(destination, opts).delete(destination)
      end 

      def disconnect(message_handler); end

      def receive_once(destination, opts={})
        exchange_strategy_for(destination, opts).receive_once(destination) do |msg|
          return msg
        end
      end

      def receive_with(message_handler)
        options = options_for(message_handler)
        destination = destination_for(message_handler)
        exchange_strategy_for(destination, options).receive(destination, message_handler)
      end

      def send_message(destination, message, options=nil)
        exchange_strategy_for(destination, options).publish(destination, message)
      end

      def unsubscribe; end

    end
  end
end
