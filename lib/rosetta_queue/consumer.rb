module RosettaQueue
  class Consumer < Base

    def self.receive(destination, options = {})
      RosettaQueue::Adapter.instance.receive_once(Destinations.lookup(destination), options)
    end

    def initialize(message_handler)
      @message_handler = message_handler
    end

    def receive
      begin
        connection.receive_with(@message_handler)
      rescue Exception=>e
        puts "caught exception: #{$!}"
      end
    end
    
  end
end