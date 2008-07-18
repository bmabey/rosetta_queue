module Messaging
  class Consumer < Base

    def listen
      connection.subscribe(queue, self.class.headers)
      begin
        while true
          msg = connection.receive
          on_message(msg.body)
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