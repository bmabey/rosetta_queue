module RosettaQueue
  module Gateway
    
    class FakeAdapter

      def initialize
        @messages = []
      end

      def send_message(queue, message, headers)
        @messages << {'queue' => queue, 'message' => RosettaQueue::Filters::process_receiving(message), 'headers' => headers}
      end
  
      def messages_sent_to(queue)
        (queue ? @messages.select{|message| message['queue'] == queue} : @messages).map{|m| m['message']}
      end
  
      def queues
        @messages.map {|message| message['queue']}
      end

    end
    
  end
  
end
