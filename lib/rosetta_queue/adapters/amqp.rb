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
        exchange_strategy_for(destination).do_single_exchange(destination, opts) do |msg|
          return msg
        end
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
            @exchange ||= FanoutExchange.new(@user, @pass, @host)
          when /queue/
            @exchange ||= DirectExchange.new(@user, @pass, @host)
          else
            @exchange ||= DirectExchange.new(@user, @pass, @host)
          end
        end
    end


    class BaseExchange

      def initialize(user, pass, host)
        @user, @pass, @host = user, pass, host
      end

      def publish_to_exchange(destination, message, options={})
        unless EM.reactor_running?
          EM.run do
            publish_message(destination, message, options)
            EM.add_timer(1) { EM.stop_event_loop }
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
          # AmqpConnect.connection(@user, @pass, @host)
          @conn ||= AMQP.connect(:user => @user, :pass => @pass, :host => @host)
        end
        
        def publish_message(dest, msg, opts)
          RosettaQueue.logger.info("Publishing to #{dest} :: #{msg}")
          channel.queue(dest).publish(msg, opts)
          channel.queue(dest).unsubscribe
        end
    end


    class DirectExchange < BaseExchange

      def do_exchange(destination, message_handler)
        channel.queue(destination).subscribe do |msg|
          RosettaQueue.logger.info("Receiving from #{destination} :: #{msg}")
          message_handler.on_message(Filters.process_receiving(msg))
        end
      end

      def do_single_exchange(destination, opts={})
        EM.run do
          channel.queue(destination).pop do |msg|
            RosettaQueue.logger.info("Receiving from #{destination} :: #{msg}")
            yield Filters.process_receiving(msg)
          end
        end
      end
    end


    class FanoutExchange < BaseExchange

      def do_exchange(destination, message_handler)
        queue     = channel.queue("queue_#{self.object_id}")
        exchange  = channel.fanout(fanout_name_for(destination))

        queue.bind(exchange).subscribe do |msg|
        # channel.queue("queue_#{rand}").bind(channel.fanout(fanout_name_for(destination))).subscribe do |msg|
          RosettaQueue.logger.info("Receiving from #{destination} :: #{msg}")
          message_handler.on_message(Filters.process_receiving(msg))
        end        
      end

      def do_single_exchange(destination, opts={})
        EM.run do
          queue     = channel.queue("queue_#{self.object_id}")
          exchange  = channel.fanout(fanout_name_for(destination))

          queue.bind(exchange).pop do |msg|
          # channel.queue("queue_#{rand}").bind(channel.fanout(fanout_name_for(destination)), opts).pop do |msg|
            RosettaQueue.logger.info("Receiving from #{destination} :: #{msg}")
            yield Filters.process_receiving(msg)
          end
        end
      end

      protected

        def publish_message(dest, msg, opts)
          exchange = channel.fanout(fanout_name_for(dest))
          exchange.publish(msg, opts)
          # channel.fanout(fanout_name_for(dest), :durable => true).publish(msg, opts)
          RosettaQueue.logger.info("Publishing to fanout #{dest} :: #{msg}")
        end

      private

        def fanout_name_for(destination)
          fanout_name = destination.gsub(/(topic|fanout)\/(.*)/, '\2')
          raise "Unable to discover fanout exchange.  Cannot bind queue to exchange!" unless fanout_name
          fanout_name
        end
    end

    class AmqpConnect

      class << self
        
        def connection(user, pass, host, port=nil)
          @conn ||= AMQP.connect(:user => user, :pass => pass, :host => host)
        end
        
      end
    end
  end
end
