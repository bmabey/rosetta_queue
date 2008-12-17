require 'mq'

# AMQP
# connections:
# - unlike stomp, we can share one connection across multiple channels
# - set host and authorization options on AMQP.connect
# 
# MQ
# create new channel for an AMQP connection
# options for queue and exchange objects include:
# - :durable => true
# - :ack => "client" ????

module RosettaQueue
  module Gateway

    class AmqpAdapter < BaseAdapter

      def initialize(user, pass, host, port=nil)
        @user, @pass, @host, @port = user, pass, host, port
      end

      def disconnect; end

      def receive_once(dest, opts={})
        EM.run do
          channel.queue(dest).pop do |msg|
            yield msg
          end
        end
      end

      def receive_with(message_handler)
        channel.queue(destination_for(message_handler)).subscribe do |msg|
          message_handler.on_message(msg)
        end
      end

      def send_message(queue, message, options=nil)
        EM.run do
          channel.queue(queue).publish(message)
          EM.add_timer(1) { EM.stop_event_loop }
        end
      end

      def unsubscribe; end
      
      private
      
        def channel
          @channel ||= MQ.new(conn)          
        end

        def conn
          @conn ||= AMQP.connect(:user => @user, :pass => @pass, :host => @host)
        end
    end
  end
end