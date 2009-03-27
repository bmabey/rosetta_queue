require 'beanstalk-client'

module RosettaQueue
  module Gateway
  
    class BeanstalkAdapter < BaseAdapter

      def ack(msg)
        @conn.ack(msg.headers["message-id"])
      end

      def initialize(user=nil, password=nil, host="localhost", port=11300)
        @host, @port = host, port
        @conn = Beanstalk::Pool.new(["#{host}:#{port}"])
      end

      def disconnect; end

      def receive(options=nil)
        @conn.reserve
      end
      
      def receive_once(destination=nil, opts={})
        receive.body
      end

      def receive_with(message_handler)
        destination = destination_for(message_handler)

        running do
          msg = receive.body
          RosettaQueue.logger.info("Receiving from #{destination} :: #{msg}")
          message_handler.on_message(filter_receiving(msg))
        end
      end
      
      def send_message(destination, message, options)
        RosettaQueue.logger.info("Publishing to #{destination} :: #{message}")        
        @conn.put(message)
      end

      private
      
        def running(&block)
          loop(&block)
        end

    end
  end
end
