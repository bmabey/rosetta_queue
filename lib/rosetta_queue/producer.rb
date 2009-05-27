module RosettaQueue
  
  class Producer < Base
    include MessageHandler

    def self.publish(destination, message, options = {})
      RosettaQueue::Adapter.instance.send_message(Destinations.lookup(destination), Filters.process_sending(message), options)

      rescue Exception=>e
        RosettaQueue.logger.error("Caught exception in Consumer#receive: #{$!}\n" + e.backtrace.join("\n\t"))
    end

  end
end
