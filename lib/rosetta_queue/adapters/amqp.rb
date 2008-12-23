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

      def receive_once(destination, opts={})
        exchange_strategy_for(destination).do_single_exchange(destination, opts)
      end

      def receive_with(message_handler)
        destination = destination_for(message_handler)
        exchange_strategy_for(destination).do_exchange(destination, message_handler)
      end

      def send_message(destination, message, options=nil)
        exchange_strategy_for(destination).publish_to_exchange(destination, message, options)
      end

      def unsubscribe; end
        
        def exchange_strategy_for(destination)
          case destination
          when /(topic|fanout)/
            @fanout_exchange ||= FanoutExchange.new(@user, @pass, @host)
          when /queue/
            @direct_exchange ||= DirectExchange.new(@user, @pass, @host)
          else
            @direct_exchange ||= DirectExchange.new(@user, @pass, @host)
          end
        end
    end


    class BaseExchange

      def initialize(user, pass, host)
        @user, @pass, @host = user, pass, host
      end

      def publish_to_exchange(destination, message, options={:persistent => true})
        unless EM.reactor_running?
          EM.run do
            publish_message(destination, message, options)
            EM.add_timer(1) { EM.stop_event_loop }
            # AMQP.stop { EM.stop_event_loop }
          end
        else
          publish_message(destination, message, options)
        end
      end      

      protected

        def channel
          @channel ||= MQ.new(conn)
        end

        def conn
          @conn ||= AMQP.connect(:user => @user, :pass => @pass, :host => @host)
        end

      private
        
        def publish_message(dest, msg, opts)
          RosettaLogger.info("Publishing to #{dest} :: #{msg}")
          channel.queue(dest).publish(msg, opts)
          channel.queue(dest).unsubscribe
        end
    end


    class DirectExchange < BaseExchange

      def do_exchange(destination, message_handler)
        channel.queue(destination).subscribe do |msg|
          RosettaLogger.info("Receiving from #{destination} :: #{msg}")
          message_handler.on_message(msg)
        end
      end

      def do_single_exchange(destination, opts={})
        EM.run do
          channel.queue(destination).pop do |msg|
            RosettaLogger.info("Receiving from #{destination} :: #{msg}")
            return msg
          end
        end
      end
    end


    class FanoutExchange < BaseExchange

      def do_exchange(destination, message_handler)
        channel.queue.bind(channel.fanout(fanout_name_for(destination))).subscribe do |msg|
          RosettaLogger.info("Receiving from #{destination} :: #{msg}")
          message_handler.on_message(msg)
        end        
      end

      def do_single_exchange(destination, opts={})
        EM.run do
          channel.queue.bind(channel.fanout(fanout_name_for(destination))).pop do |msg|
            RosettaLogger.info("Receiving from #{destination} :: #{msg}")
            return msg
          end
        end
      end

      private

        def fanout_name_for(destination)
          fanout_name = destination.gsub(/(topic|fanout)\/(.*)/, '\2')
          raise "Unable to discover fanout exchange.  Cannot bind queue to exchange!" unless fanout_name
          fanout_name
        end

    end
  end
end