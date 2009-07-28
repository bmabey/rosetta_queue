module RosettaQueue
  module Gateway

    module Fanout
      def fanout_name_for(destination)
        fanout_name = destination.gsub(/(topic|fanout)\/(.*)/, '\2')
        raise AdapterException, "Unable to discover fanout exchange. Cannot bind queue to exchange!" unless fanout_name
        fanout_name
      end
    end 

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
