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

      def disconnect
        @exchange_strategy.unsubscribe if @exchange_strategy
      end

      def receive_once(destination, opts={})
        @exchange_strategy = exchange_strategy_for(destination, opts)
        @exchange_strategy.receive_once(destination) do |msg|
          return msg
        end
      end

      def receive_with(message_handler)
        options = options_for(message_handler)
        destination = destination_for(message_handler)
        @exchange_strategy = exchange_strategy_for(destination, options)
        @exchange_strategy.receive(destination, message_handler)
      end

      def send_message(destination, message, options=nil)
        @exchange_strategy = exchange_strategy_for(destination, options)
        @exchange_strategy.publish(destination, message)
      end

      def unsubscribe; end

    end

    class AmqpEventedAdapter < Amqp

      def exchange_strategy_for(destination, options)
        case destination
        when /^fanout\./
          @exchange ||= EventedExchange::FanoutExchange.new(@adapter_settings, options)
        when /^topic\./
          raise "Sorry.  RosettaQueue can not process AMQP topics yet"
        when /^queue\./
          @exchange ||= EventedExchange::DirectExchange.new(@adapter_settings, options)
        else
          @exchange ||= EventedExchange::DirectExchange.new(@adapter_settings, options)
        end
      end
    end


    # This AMQP adapter utilizes the synchronous AMPQ client 'Bunny'
    # by celldee (http://github.com/celldee/bunny)
    class AmqpSynchAdapter < Amqp

      def exchange_strategy_for(destination, options={})
        case destination
        when /^fanout\./
          @exchange ||= SynchExchange::FanoutExchange.new(@adapter_settings, options)
        when /^topic\./
          raise "Sorry.  RosettaQueue can not process AMQP topics yet"
        when /^queue\./
          @exchange ||= SynchExchange::DirectExchange.new(@adapter_settings, options)
        else
          @exchange ||= SynchExchange::DirectExchange.new(@adapter_settings, options)
        end
      end
    end

  end
end
