require 'amqp'
require File.expand_path(File.dirname(__FILE__) + "/amqp.rb")

module RosettaQueue
  module Gateway
 
    class AmqpEventedAdapter < Amqp
      private

      def exchange_strategy_for(destination, options)
        case destination
        when /^fanout\./
          @exchange ||= EventedExchangeStrategies::FanoutExchange.new(@adapter_settings, options)
        when /^topic\./
          raise "Sorry.  RosettaQueue can not process AMQP topics yet"
        when /^queue\./
          @exchange ||= EventedExchangeStrategies::DirectExchange.new(@adapter_settings, options)
        else
          @exchange ||= EventedExchangeStrategies::DirectExchange.new(@adapter_settings, options)
        end
      end
    end
 
    module EventedExchangeStrategies

      class BaseExchange
        
        def initialize(adapter_settings, options={})
          @adapter_settings, @options = adapter_settings, options
        end

        def delete(destination)
          conn.queue(destination).delete(@options)
        end 

        protected
        
        def channel
          @channel ||= MQ.new(conn)
        end
        
        def conn
          vhost = @adapter_settings[:opts][:vhost] || "/" 
          @conn ||= AMQP.connect(:user => @adapter_settings[:user], 
                                 :pass => @adapter_settings[:pass], 
                                 :host => @adapter_settings[:host], 
                                 :vhost => vhost)
        end
      end
      
      
      class DirectExchange < BaseExchange

        def receive_once(destination, options={})
          raise AdapterException, "Consumers need to run in an EventMachine 'run' block. (e.g., EM.run { RosettaQueue::Consumer.receive }" unless EM.reactor_running?

          queue = conn.queue(destination, @options)
          queue.pop(@options) do |msg|
            RosettaQueue.logger.info("Receiving from #{destination} :: #{msg}")
            yield Filters.process_receiving(msg)
          end
        end

        def receive(destination, message_handler)
          raise AdapterException, "Consumers need to run in an EventMachine 'run' block.  Try wrapping them inside the evented consumer manager." unless EM.reactor_running?

          queue = channel.queue(destination)
          ack = @options[:ack]
          queue.subscribe(@options) do |msg|
            RosettaQueue.logger.info("Receiving from #{destination} :: #{msg}")
            message_handler.on_message(Filters.process_receiving(msg))
            queue.ack if ack
          end
        end

        def publish(destination, message, options={})
          raise AdapterException, "Messages need to be published in an EventMachine run block (e.g., EM.run { RosettaQueue::Producer.publish(:foo, msg) } " unless EM.reactor_running?

          RosettaQueue.logger.info("Publishing to #{dest} :: #{msg}")
          queue = channel.queue(destination, options)
          queue.publish(message, options)
          queue.unsubscribe
        end
        
      end
      
      
      class FanoutExchange < BaseExchange

        def receive_once(destination, opts={})
          raise AdapterException, "Consumers need to run in an EventMachine 'run' block. (e.g., EM.run { RosettaQueue::Consumer.receive }" unless EM.reactor_running?

          queue = channel.queue("queue_#{self.object_id}")
          exchange = channel.fanout(fanout_name_for(destination), opts)
          
          queue.bind(exchange).pop(opts) do |msg|
            RosettaQueue.logger.info("Receiving from #{destination} :: #{msg}")
            yield Filters.process_receiving(msg)
          end
        end
        
        def receive(destination, message_handler)
          raise AdapterException, "Consumers need to run in an EventMachine 'run' block.  Try wrapping them inside the evented consumer manager." unless EM.reactor_running?

          queue = channel.queue("queue_#{self.object_id}")
          exchange = channel.fanout(fanout_name_for(destination), @options)
          
          queue.bind(exchange).subscribe(@options) do |msg|
            RosettaQueue.logger.info("Receiving from #{destination} :: #{msg}")
            message_handler.on_message(Filters.process_receiving(msg))
          end
        end
        
        def publish_message(dest, msg, opts)
          raise AdapterException, "Messages need to be published in an EventMachine run block (e.g., EM.run { RosettaQueue::Producer.publish(:foo, msg) } " unless EM.reactor_running?

          exchange = channel.fanout(fanout_name_for(dest), opts)
          exchange.publish(msg, opts)
          RosettaQueue.logger.info("Publishing to fanout #{dest} :: #{msg}")
        end
        
        private
        
        def fanout_name_for(destination)
          fanout_name = destination.gsub(/(topic|fanout)\/(.*)/, '\2')
          raise AdapterException, "Unable to discover fanout exchange. Cannot bind queue to exchange!" unless fanout_name
          fanout_name
        end
      end
    end
  end 
end
