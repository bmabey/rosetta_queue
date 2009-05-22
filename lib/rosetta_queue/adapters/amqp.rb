require 'mq'

module RosettaQueue
  module Gateway

    class AmqpAdapter < AmqpBaseAdapter

      def exchange_strategy_for(destination, options)
        case destination
        when /fanout/
          @exchange ||= AmqpExchangeStrategies::FanoutExchange.new(@adapter_settings, options)
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

        def publish(destination, message)
          unless EM.reactor_running?
            EM.run do
              publish_message(destination, message)
              EM.add_timer(1) { EM.stop_event_loop }
            end
          else
            publish_message(destination, message)
          end
        end      

        protected

        def channel
          @channel ||= MQ.new(conn)
        end

        def conn
          vhost = @adapter_settings[:opts][:vhost] || "/" 
          @conn ||= AMQP.connect(:user => @adapter_settings[:user], 
                                 :pass => @adapter_settings[:password], 
                                 :host => @adapter_settings[:host], 
                                 :vhost => vhost)
        end
        
        def publish_message(dest, msg)
          RosettaQueue.logger.info("Publishing to #{dest} :: #{msg}")
          channel.queue(dest).publish(msg, @options)
          channel.queue(dest).unsubscribe
        end
      end


      class DirectExchange < BaseExchange

        def receive(destination, message_handler)
          channel.queue(destination).subscribe(@options) do |msg|
            RosettaQueue.logger.info("Receiving from #{destination} :: #{msg}")
            message_handler.on_message(Filters.process_receiving(msg))
          end
        end

        def receive_once(destination)
          EM.run do
            channel.queue(destination).pop(@options) do |msg|
              RosettaQueue.logger.info("Receiving from #{destination} :: #{msg}")
              yield Filters.process_receiving(msg)
            end
          end
        end
      end


      class FanoutExchange < BaseExchange

        def receive(destination, message_handler)
          queue = channel.queue("queue_#{self.object_id}")
          exchange = channel.fanout(fanout_name_for(destination))
          
          queue.bind(exchange).subscribe(@options) do |msg|
            RosettaQueue.logger.info("Receiving from #{destination} :: #{msg}")
            message_handler.on_message(Filters.process_receiving(msg))
          end        
        end

        def receive_once(destination)
          EM.run do
            queue = channel.queue("queue_#{self.object_id}")
            exchange = channel.fanout(fanout_name_for(destination))

            queue.bind(exchange).pop(@options) do |msg|
              RosettaQueue.logger.info("Receiving from #{destination} :: #{msg}")
              yield Filters.process_receiving(msg)
            end
          end
        end

        protected

        def publish_message(dest, msg)
          exchange = channel.fanout(fanout_name_for(dest))
          exchange.publish(msg, @options)
          RosettaQueue.logger.info("Publishing to fanout #{dest} :: #{msg}")
        end

        private

        def fanout_name_for(destination)
          fanout_name = destination.gsub(/(topic|fanout)\/(.*)/, '\2')
          raise "Unable to discover fanout exchange.  Cannot bind queue to exchange!" unless fanout_name
          fanout_name
        end
      end
    end 
  end
end
