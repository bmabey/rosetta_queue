require 'bunny'
require File.expand_path(File.dirname(__FILE__) + "/amqp.rb")

module RosettaQueue
  module Gateway

    # This AMQP adapter utilizes the synchronous AMPQ client 'Bunny'
    # by celldee (http://github.com/celldee/bunny)
    class AmqpSynchAdapter < Amqp
      private

      def exchange_strategy_for(destination, options)
        case destination
        when /^fanout\./
          @exchange ||= SynchExchangeStrategies::FanoutExchange.new(@adapter_settings, options)
        when /^topic\./
          raise "Sorry.  RosettaQueue can not process AMQP topics yet"
        when /^queue\./
          @exchange ||= SynchExchangeStrategies::DirectExchange.new(@adapter_settings, options)
        else
          @exchange ||= SynchExchangeStrategies::DirectExchange.new(@adapter_settings, options)
        end
      end
    end 

    module SynchExchangeStrategies

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
          @conn ||= Bunny.new( :user => @adapter_settings[:user], 
                               :pass => @adapter_settings[:password], 
                               :host => @adapter_settings[:host], 
                               :vhost => vhost)
          @conn.start unless @conn.status == :connected
          @conn
        end
      end

      class DirectExchange < BaseExchange

        def publish(destination, message, options={})
          RosettaQueue.logger.info("Publishing to #{destination} :: #{message}")
          queue = conn.queue(destination, options)
          queue.publish(message, options)
          queue.unsubscribe
        end      

        def receive(destination, message_handler)
          queue = conn.queue(destination, @options)
          ack = @options[:ack]
          queue.subscribe(@options) do |msg|
            RosettaQueue.logger.info("Receiving from #{destination} :: #{msg}")
            message_handler.on_message(Filters.process_receiving(msg))
            queue.ack if ack
          end 
        end

        def receive_once(destination)
          queue = conn.queue(destination, @options)
          ack = @options[:ack]
          msg = queue.pop(@options)
          RosettaQueue.logger.info("Receiving from #{destination} :: #{msg}")
          queue.ack if ack
          yield Filters.process_receiving(msg)
        end

      end

      class FanoutExchange < BaseExchange
        
        def fanout_name_for(destination)
          fanout_name = destination.gsub(/fanout\/(.*)/, '\1')
          raise AdapterException, "Unable to discover fanout exchange.  Cannot bind queue to exchange!" unless fanout_name
          fanout_name
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

        def receive_once(destination, options={})
          queue = conn.queue("queue_#{self.object_id}", options)
          exchange = conn.fanout(fanout_name_for(destination), options)

          msg = queue.bind(exchange).pop(@options)
          RosettaQueue.logger.info("Receiving from #{destination} :: #{msg}")
          yield Filters.process_receiving(msg)
        end

      end 
    end 
  end
end
