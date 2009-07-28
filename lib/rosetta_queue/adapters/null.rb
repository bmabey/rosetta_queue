module RosettaQueue
  module Gateway
    
    # The null adapter lets all send messages enter into the ether and so is ideal for modes
    # when you do not want to incur the overhead of a real adapter.  You can not consume with 
    # this adapter however.
    #
    # In your RosettaQueue definition block, and your using rails, you could base your adapter type on Rails.env:
    #
    # RosettaQueue::Adapter.define do |a|
    #   if Rails.env == 'production' || ENV["RUNNING_STORIES"] == "true"
    #     a.user = ""
    #     a.password = ""
    #     a.host = "localhost"
    #     a.port = 61613
    #     a.type = "stomp"
    #   else
    #     a.type = "null"
    #   end
    # end
    # 
    # (if you follow this example and are using stories be sure 
    # to set ENV["RUNNING_STORIES"] = "true" in your helper.rb or env.rb file)
    class NullAdapter
                    
      def initialize(adapter_settings)
        # no-op
      end

      def disconnect
        # no-op
      end
      
      def receive
        raise "Null Adpater is in use, you can not consume messages!"
      end
      
      def receive_with(message_handler)
        raise "Null Adpater is in use, you can not consume messages!"
      end
      
      def send_message(queue, message, options)
        # no-op
      end

      def subscribe(queue, options)
        # no-op
      end
          
      def unsubscribe(queue)
        # no-op
      end


    end
  end
end
