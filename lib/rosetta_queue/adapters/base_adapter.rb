module RosettaQueue
  module Gateway

    class BaseAdapter
  
      protected

        def options_for(message_handler)
          (message_handler.options_hash) || {}
          # unless message_handler.options_hash.nil?
          #   message_handler.options_hash
          # else
          #   {}
          # end
        end

        def destination_for(message_handler)
          raise DestinationNotFound.new("Missing destination!") unless message_handler.destination
          @dest ||= Destinations.lookup(message_handler.destination.to_sym)
        end
  
    end
  end
end