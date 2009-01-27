module RosettaQueue
  module MessageHandler
    
    module ClassMethods

      attr_reader :destination, :options_hash

      def options(options = {})
        @options_hash = options
      end

      def publishes_to(destination)
        @destination = destination
      end

      def subscribes_to(destination)
        @destination = destination
      end
    end
    
    def self.included(receiver)
      receiver.extend(ClassMethods)

      def destination
        self.class.destination  
      end
      
      def options_hash
        self.class.options_hash
      end
    end
  end
end
