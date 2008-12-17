require 'stomp'

module RosettaQueue
  module Gateway
  
    class StompAdapter < BaseAdapter

      def ack(msg)
        @conn.ack(msg.headers["message-id"])
      end

      def initialize(user, password, host, port)
        @conn = Stomp::Connection.open(user, password, host, port, true)
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
      
      def receive_once(dest, opts)
        subscribe(dest, opts)
        msg = receive(opts).body
        unsubscribe(dest)
        msg
      end

      def receive_with(message_handler)
        options = options_for(message_handler)
        @conn.subscribe(destination_for(message_handler), options)

        running do          
          message_handler.on_message(receive(options).body)
        end
      end
      
      def send_message(queue, message, options)
        @conn.send(queue, message, options)
      end

      def subscribe(queue, options)
        @conn.subscribe(queue, options)
      end
          
      def unsubscribe(queue)
        @conn.unsubscribe(queue)
      end
      
      private
      
        def running(&block)
          loop(&block)
        end

    end
  end
end