require 'stomp'

module Messaging
  module Gateway
  
    class StompAdapter

      class << self
        
        def open(user, password, host, port)
          self.new.connect(user, password, host, port)
        end

      end

      def ack(id)
        @conn.ack(id)
      end

      def connect(user, password, host, port)
        @conn ||= Stomp::Connection.open(user, password, host, port, true)
      end

      def disconnect
        @conn.disconnect
      end
      
      def receive
        @conn.receive
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

    end
  end
end