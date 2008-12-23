module RosettaQueue
  class Consumer < Base

    def self.receive(destination, options = {})
      # debugger
      RosettaQueue::Adapter.instance.receive_once(Destinations.lookup(destination), options)
      
      rescue Exception=>e
        RosettaLogger.error("Caught exception in Consumer#receive: #{$!}\n" + e.backtrace.join("\n\t"))
    end

    def initialize(message_handler)
      @message_handler = message_handler
    end

    def receive
      connection.receive_with(@message_handler)
      
      rescue Exception=>e
        RosettaLogger.error("Caught exception in Consumer#receive: #{$!}\n" + e.backtrace.join("\n\t"))
    end

  end
end