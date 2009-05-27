require 'carrot'

module RosettaQueue
  module Gateway

    # This AMQP adapter utilizes a forked version of the synchronous AMPQ client 'Carrot'
    # by famoseagle (http://github.com/famoseagle)
    class AmqpAdapter < BaseAdapter

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

      private

      def exchange_strategy_for(destination, options)
        case destination
        when /fanout/
          @exchange ||= AmqpExchangeStrategies::FanoutExchange.new(@adapter_settings, options)
        when /topic/
          raise "Sorry.  RosettaQueue can not process AMQP topics yet"
        when /queue/
          @exchange ||= AmqpExchangeStrategies::DirectExchange.new(@adapter_settings, options)
        else
          @exchange ||= AmqpExchangeStrategies::DirectExchange.new(@adapter_settings, options)
        end
      end

    end 

    module AmqpExchangeStrategies

      class BaseExchange

        def initialize(adapter_settings, options={})
          @adapter_settings, @options = adapter_settings, options
        end

        def delete(destination)
          conn.queue(destination).delete(@options)
        end 

        protected
        def conn
          vhost = @adapter_settings[:opts][:vhost] || "/" 
          @conn ||= Carrot.new(:user => @adapter_settings[:user], 
                               :pass => @adapter_settings[:password], 
                               :host => @adapter_settings[:host], 
                               :vhost => vhost)
        end
      end

      class DirectExchange < BaseExchange

        def publish(destination, message, options={})
          RosettaQueue.logger.info("Publishing to #{destination} :: #{message}")
          conn.queue(destination, options).publish(message, options)
        end      

        def receive(destination, message_handler)
          conn.queue(destination, @options).subscribe(@options) do |msg|
            RosettaQueue.logger.info("Receiving from #{destination} :: #{msg}")
            message_handler.on_message(Filters.process_receiving(msg))
          end 
        end

        def receive_once(destination, options={})
          msg = conn.queue(destination, options).pop(options)
          RosettaQueue.logger.info("Receiving from #{destination} :: #{msg}")
          yield Filters.process_receiving(msg)
        end
      end

      class FanoutExchange < BaseExchange
        
        def fanout_name_for(destination)
          fanout_name = destination.gsub(/fanout\/(.*)/, '\1')
          raise "Unable to discover fanout exchange.  Cannot bind queue to exchange!" unless fanout_name
          fanout_name
        end

        def receive_once(destination, options={})
          queue = conn.queue("queue_#{self.object_id}", options)
          exchange = conn.fanout(fanout_name_for(destination), options)

          msg = queue.bind(exchange).pop(@options)
          RosettaQueue.logger.info("Receiving from #{destination} :: #{msg}")
          yield Filters.process_receiving(msg)
        end

        def publish(destination, message, options={})
          exchange = conn.fanout(fanout_name_for(destination), options)
          exchange.publish(message, options)
          RosettaQueue.logger.info("Publishing to fanout #{destination} :: #{message}")
        end      

        def receive(destination, message_handler)
          queue = conn.queue("queue_#{self.object_id}", @options)
          exchange = conn.fanout(fanout_name_for(destination), @options)

          msg = queue.bind(exchange).subscribe(@options) do |msg|

            RosettaQueue.logger.info("Receiving from #{destination} :: #{msg}")
            message_handler.on_message(Filters.process_receiving(msg))
          end        
        end
      end 
    end 
  end
end
