module Messaging
  
  class Base

    def initialize
      @consumers = []
    end
    
    def add(consumer_strategy)
      @consumer_strategy = consumer_strategy
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
       unless @consumer_strategy.options_hash.nil?
         @consumer_strategy.options_hash
       else
         {}
       end
     end

     def queue
       raise DestinationNotFound.new("Missing queue destination.  Cannot publish message!") unless @consumer_strategy.destination
       @queue ||= Destinations.lookup(@consumer_strategy.destination.to_sym)
     end
  end
end