module Messaging
  
  class Base
    
    class << self
      attr_reader :destination, :options_hash

      def options(options = {})
        @options_hash = options
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
       @conn ||= Adapter.instance
     end

     def options
       unless self.class.options_hash.nil?
         self.class.options_hash
       else
         {}
       end
     end

     def queue
       raise DestinationNotFound.new("Missing queue destination.  Cannot publish message!") unless self.class.destination
       @queue ||= Destinations.lookup(self.class.destination.to_sym)
     end
  end
end