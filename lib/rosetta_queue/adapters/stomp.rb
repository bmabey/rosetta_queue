require 'stomp'

module RosettaQueue
  module Gateway
  
    class StompAdapter < BaseAdapter

      def ack(msg)
        @conn.ack(msg.headers["message-id"])
      end

      def initialize(adapter_settings = {})
        raise "Missing adapter settings" if adapter_settings.empty?
        @conn = Stomp::Connection.open(adapter_settings[:user], 
                                       adapter_settings[:password], 
                                       adapter_settings[:host], 
                                       adapter_settings[:port], 
                                       true)
      end

      def disconnect(message_handler)
        unsubscribe(destination_for(message_handler))
        @conn.disconnect
      end

      def receive(options)
        msg = @conn.receive
        ack(msg) unless options[:ack].nil?
        msg
      end
      
      def receive_once(destination, opts)
        subscribe(destination, opts)
        msg = receive(opts).body
        unsubscribe(destination)
        RosettaQueue.logger.info("Receiving from #{destination} :: #{msg}")
        filter_receiving(msg)
      end

      def receive_with(message_handler)
        options = options_for(message_handler)
        destination = destination_for(message_handler)
        @conn.subscribe(destination, options)

        running do
          msg = receive(options).body
          Thread.current[:processing] = true
          RosettaQueue.logger.info("Receiving from #{destination} :: #{msg}")
          message_handler.on_message(filter_receiving(msg))
          Thread.current[:processing] = false
        end
      end
      
      def send_message(destination, message, options)
        RosettaQueue.logger.info("Publishing to #{destination} :: #{message}")        
        @conn.send(destination, message, options)
      end

      def subscribe(destination, options)
        @conn.subscribe(destination, options)
      end
          
      def unsubscribe(destination)
        @conn.unsubscribe(destination)
      end
      
      private
      
        def running(&block)
          loop(&block)
        end

    end
  end
end
