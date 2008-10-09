module Messaging
  class Consumer < Base

    def self.receive(destination, options = {})
      connection = Messaging::Adapter.instance
      connection.subscribe(Destinations.lookup(destination), options)
      message = connection.receive.body
      connection.unsubscribe(Destinations.lookup(destination))
      message
    end

    def initialize(message_handler)
      @message_handler = message_handler
    end

    def receive
      begin
        puts "listening on queue #{destination}" unless ENV["MESSAGING_ENV"] == "test"
        connection.subscribe(destination, options)
        connection.receive_with(@message_handler)
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