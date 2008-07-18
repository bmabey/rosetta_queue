module Messaging
  
  class Base
    class << self
      attr_reader :destination, :headers
  
      def options(args)
        @headers = args
      end
  
      def subscribes_to(destination)
        @destination = destination
      end

      def publishes_to(destination)
        @destination = destination
      end
    end  

    def disconnect
      connection.disconnect
    end

    def unsubscribe
      connection.unsubscribe(queue)
    end
  
    protected
     def connection
       @conn ||= Stomp::Connection.open(USER, PASSWORD, HOST, PORT, true)
     end

     def queue
       raise "Missing queue destination.  Cannot publish message." unless self.class.destination
       @queue ||= Destinations.queue[self.class.destination.to_sym]
     end
  end
end