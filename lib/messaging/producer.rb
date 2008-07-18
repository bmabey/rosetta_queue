module Messaging
  
  class Producer < Base

    def publish(message)

      begin
        connection.send(queue, message, self.class.headers)
      rescue Exception=>e
        puts "caught exception: #{$!}"
        e.log_error
        e.send_notification
      end
    end
    
  end
end