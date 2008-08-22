module Messaging
  
  class Producer < Base

    class << self

      def publishes_to(destination)
        @destination = destination
      end

      def publish(destination, message, options = {})
        begin
          Messaging::Adapter.instance.send(Destinations.lookup(destination), message, options)
        rescue Exception=>e
          raise e.backtrace
        end
      end

    end

    def publish(message)
      begin
        connection.send(queue, message, options)
      rescue Exception=>e
        puts "caught exception: #{$!}"
        e.log_error
        e.send_notification
      end
    end

  end
end