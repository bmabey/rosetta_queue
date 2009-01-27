module RosettaQueue
  module Gateway

    class BaseAdapter
  
      protected

        def options_for(message_handler)
          (message_handler.options_hash) || {}
        end

        def destination_for(message_handler)
          raise DestinationNotFound.new("Missing destination!") unless message_handler.destination
          @dest ||= Destinations.lookup(message_handler.destination.to_sym)
        end
        
        def filter_receiving(msg)
          Filters.process_receiving(msg)
        end

        def filter_sending(msg)
          Filters.process_sending(msg)
        end
  
    end
  end
end