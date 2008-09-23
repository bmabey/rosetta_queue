module Messaging
  
  class Producer < Base
    include MessageHandler

    def self.publish(destination, message, options = {})
      Messaging::Adapter.instance.send_message(Destinations.lookup(destination), message, options)
    end

    def publish(message)
      #TODO redo how exceptions are handled...
      begin
        connection.send_message(publish_destination, message, options)
      rescue Exception=>e
        puts "caught exception: #{$!}"
        e.log_error
        e.send_notification
      end
    end

    protected

      def options
        unless options_hash.nil?
          options_hash
        else
          {}
        end
      end

      def publish_destination
        raise DestinationNotFound.new("Missing destination.  Cannot publish message!") unless destination
        @dest ||= Destinations.lookup(destination.to_sym)
      end

  end
end