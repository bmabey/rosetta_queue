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
    end

    attr_accessor :adapter_proxy

    def destination
      self.class.destination
    end

    def options_hash
      self.class.options_hash
    end

    def handle_message(unfiltered_message)
      ExceptionHandler::handle(:publishing,
        lambda {
          { :message => Filters.safe_process_receiving(unfiltered_message),
            :destination => destination,
            :action => :consuming,
            :options => options_hash
          }
        } ) do
        on_message(Filters.process_receiving(unfiltered_message))
      end
    end

    def ack
      adapter_proxy.ack unless adapter_proxy.nil?
    end

  end
end
