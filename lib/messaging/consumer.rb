module Messaging
  class Consumer < Base

    class << self

      def receive(destination, options = {})
        conn = Messaging::Adapter.instance
        conn.subscribe(Destinations.lookup(destination), options)
        msg = conn.receive.body
        conn.unsubscribe(Destinations.lookup(destination))
        msg
      end
    end

    def receive
      begin
        connection.subscribe(queue, options)
        while true
          puts "listening on queue #{queue}" unless ENV["MESSAGING_ENV"] == "test"
          msg = connection.receive
          @consumer_strategy.on_message(msg)
          connection.ack(msg.headers["message-id"])
        end
      rescue Exception=>e
        puts "caught exception: #{$!}"
        e.log_error
        e.send_notification
      end
    end
  end
end