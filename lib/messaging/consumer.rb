module Messaging
  class Consumer < Base

    def initialize(message_handler)
      @message_handler = message_handler
    end

    def self.receive(dest, options = {})
      conn = Messaging::Adapter.instance
      conn.subscribe(Destinations.lookup(dest), options)
      msg = conn.receive.body
      conn.unsubscribe(Destinations.lookup(dest))
      msg
    end

    def receive
      begin
        puts "listening on queue #{destination}" unless ENV["MESSAGING_ENV"] == "test"
        connection.subscribe(destination, options)
        connection.receive(@message_handler)
      rescue Exception=>e
        puts "caught exception: #{$!}"
        e.log_error
        e.send_notification
      end
    end

    protected
    
      def options
        unless @message_handler.options_hash.nil?
          @message_handler.options_hash
        else
          {}
        end
      end

      def destination
        raise DestinationNotFound.new("Missing destination.  Cannot consume message!") unless @message_handler.destination
        @dest ||= Destinations.lookup(@message_handler.destination.to_sym)
      end
    
  end
end