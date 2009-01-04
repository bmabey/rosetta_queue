module RosettaQueue
  
  class Producer < Base
    include MessageHandler

    def self.publish(destination, message, options = {})
      RosettaQueue::Adapter.instance.send_message(Destinations.lookup(destination), Filters.process_sending(message), options)

      rescue Exception=>e
        RosettaLogger.error("Caught exception in Consumer#receive: #{$!}\n" + e.backtrace.join("\n\t"))
    end

    # def publish(message)
    #   begin
    #     connection.send_message(publish_destination, message, options)
    #   rescue Exception=>e
    #     RosettaLogger.error("Caught exception in Producer#publish: #{$!}\n" + e.backtrace.join("\n\t"))
    #   end
    # end

  end
end