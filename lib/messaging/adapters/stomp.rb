require 'stomp'

module Messaging
  module Gateway
  
    class StompAdapter
        
      def self.open(user, password, host, port)
        self.new(user, password, host, port)
      end

      def ack(msg)
        @conn.ack(msg.headers["message-id"])
      end

      def initialize(user, password, host, port)
        @conn = Stomp::Connection.open(user, password, host, port, true)
      end

      def disconnect
        @conn.disconnect
      end
      
      def receive(message_handler)
        running do
          msg = @conn.receive
          message_handler.on_message(msg.body)
          ack(msg)
        end
      end
      
      def send(queue, message, options)
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