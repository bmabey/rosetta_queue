module RosettaQueue
  class Consumer

    def self.receive(destination, options = {})
      RosettaQueue::Adapter.open { |a| return a.receive_once(Destinations.lookup(destination), options) }

    rescue Exception=>e
        RosettaQueue.logger.error("Caught exception in Consumer.receive: #{$!}\n" + e.backtrace.join("\n\t"))
    end

    def self.delete(destination, options={})
      RosettaQueue::Adapter.open { |a| a.delete(Destinations.lookup(destination), options)}

      rescue Exception=>e
        RosettaQueue.logger.error("Caught exception in Consumer.delete: #{$!}\n" + e.backtrace.join("\n\t"))
    end

    def initialize(message_handler)
      @message_handler = message_handler
    end

    def receive
      connection.receive_with(@message_handler)

      rescue Exception=>e
        RosettaQueue.logger.error("Caught exception in Consumer#receive: #{$!}\n" + e.backtrace.join("\n\t"))
    end

    private

    def connection
      @conn ||= Adapter.open
    end

  end
end
