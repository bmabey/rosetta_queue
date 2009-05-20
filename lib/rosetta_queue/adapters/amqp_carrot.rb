require 'carrot'

module RosettaQueue
  module Gateway

    class AmqpCarrotAdapter < BaseAdapter
      include AmqpBaseAdapter
    end

    class BaseExchange

      def initialize(adapter_settings, options={})
        @adapter_settings, @options = adapter_settings, options
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
        conn.queue(destination).publish(message, options)
      end      

      def receive(destination, message_handler)
        conn.queue(destination).subscribe(@options) do |msg|
          RosettaQueue.logger.info("Receiving from #{destination} :: #{msg}")
          message_handler.on_message(Filters.process_receiving(msg))
        end 
      end

      def receive_once(destination)
        msg = conn.queue(destination).pop(@options)
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

      def receive_once(destination)
        queue = conn.queue("queue_#{self.object_id}")
        exchange = conn.fanout(fanout_name_for(destination))

        msg = queue.bind(exchange).pop(@options)
        RosettaQueue.logger.info("Receiving from #{destination} :: #{msg}")
        yield Filters.process_receiving(msg)
      end

      def publish(destination, message, options={})
        exchange = conn.fanout(fanout_name_for(destination))
        exchange.publish(message, @options)
        RosettaQueue.logger.info("Publishing to fanout #{destination} :: #{message}")
      end      

      def receive(destination, message_handler)
        queue = conn.queue("queue_#{self.object_id}")
        exchange = conn.fanout(fanout_name_for(destination))

        msg = queue.bind(exchange).subscribe(@options) do |msg|

          RosettaQueue.logger.info("Receiving from #{destination} :: #{msg}")
          message_handler.on_message(Filters.process_receiving(msg))
        end        
      end
    end 
  end
end
