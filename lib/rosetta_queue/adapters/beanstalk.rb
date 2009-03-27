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

      # TODO: support options[:timeout] ?
      def receive(options=nil)
        msg = @conn.reserve
        msg.delete
        msg
      end
      
      def receive_once(destination=nil, opts={})
        receive.body
      end

      def receive_with(message_handler)
        # Note that, while we call destination_for (to comply with
        # Rosetta's generic specs), beanstalk doesn't actually support
        # destinations. This is just for compatibility.
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
