require 'stomp'

module RosettaQueue
  module Gateway

    class StompAdapter < BaseAdapter

      def ack(msg)
        raise AdapterException, "Unable to ack client because message-id is blank.  Are your message handler options correct? (i.e., :ack => 'client')" if msg.headers["message-id"].nil?
        @conn.ack(msg.headers["message-id"])
      end

      def initialize(adapter_settings = {})
        raise AdapterException, "Missing adapter settings" if adapter_settings.empty?
        @conn = Stomp::Connection.open(adapter_settings[:user],
                                       adapter_settings[:password],
                                       adapter_settings[:host],
                                       adapter_settings[:port],
                                       true)
      end

      def disconnect
        unsubscribe if @destination
        @conn.disconnect
      end

      def receive(options)
        msg = @conn.receive
        ack(msg) unless options[:ack].nil?
        msg
      end

      def receive_once(destination, opts)
        @destination, @options = destination, opts
        subscribe
        msg = receive(@options).body
        unsubscribe
        RosettaQueue.logger.info("Receiving from #{@destination} :: #{msg}")
        filter_receiving(msg)
      end

      def receive_with(message_handler)
        @destination, @options = destination_for(message_handler), options_for(message_handler)
        subscribe
        running do
          msg = receive(@options).body
          Thread.current[:processing] = true
          RosettaQueue.logger.info("Receiving from #{@destination} :: #{msg}")
          message_handler.handle_message(msg)
          Thread.current[:processing] = false
        end
      end

      def send_message(destination, message, options)
        @destination = destination
        RosettaQueue.logger.info("Publishing to #{@destination} :: #{message}")
        @conn.send(@destination, message, options)
      end

      def subscribe
        @conn.subscribe(@destination, @options)
      end

      def unsubscribe
        @conn.unsubscribe(@destination)
      end

      private

        def running(&block)
          loop(&block)
        end

    end

  end
end
