require 'eventmachine'
require 'mq'
require File.expand_path(File.dirname(__FILE__) + "/amqp.rb")

module RosettaQueue
  module Gateway

    module EventedExchange

      class BaseExchange

        def initialize(adapter_settings, options={})
          @adapter_settings, @options = adapter_settings, options
        end

        def delete(destination)
          conn.queue(destination).delete(@options)
        end

        protected

        def channel
          @channel ||=  MQ.new(conn)
        end

        def conn
          vhost = @adapter_settings[:opts][:vhost] || "/"
          @conn ||= AMQP.connect(:user => @adapter_settings[:user],
                                 :pass => @adapter_settings[:password],
                                 :host => @adapter_settings[:host],
                                 :vhost => vhost)
        end
      end


      class DirectExchange < BaseExchange

        def publish(destination, message, options={})
          raise AdapterException, "Messages need to be published in an EventMachine run block (e.g., EM.run { RosettaQueue::Producer.publish(:foo, msg) } " unless EM.reactor_running?

          queue = channel.queue(destination, options)
          queue.publish(message, options)
          RosettaQueue.logger.info("Publishing to #{destination} :: #{message}")
          queue.unsubscribe
        end

        def receive(destination, message_handler)
          raise AdapterException, "Consumers need to run in an EventMachine 'run' block.  Try wrapping them inside the evented consumer manager." unless EM.reactor_running?

          queue = channel.queue(destination, @options)
          ack = @options[:ack]
          queue.subscribe(@options) do |header, msg|
            RosettaQueue.logger.info("Receiving from #{destination} :: #{msg}")
            message_handler.handle_message(msg)
            header.ack if ack
          end
        end

        def receive_once(destination, options={})
          raise AdapterException, "Consumers need to run in an EventMachine 'run' block. (e.g., EM.run { RosettaQueue::Consumer.receive }" unless EM.reactor_running?

          queue = channel.queue(destination, @options)
          ack = @options[:ack]
          queue.pop(@options) do |header, msg|
            RosettaQueue.logger.info("Receiving from #{destination} :: #{msg}")
            header.ack if ack
            yield Filters.process_receiving(msg)
          end
        end
      end


      class FanoutExchange < BaseExchange
        include Fanout

        def publish(dest, msg, opts)
          raise AdapterException, "Messages need to be published in an EventMachine run block (e.g., EM.run { RosettaQueue::Producer.publish(:foo, msg) } " unless EM.reactor_running?

          exchange = channel.fanout(fanout_name_for(dest), opts)
          exchange.publish(msg, opts)
          RosettaQueue.logger.info("Publishing to fanout #{dest} :: #{msg}")
        end

        def receive(destination, message_handler)
          raise AdapterException, "Consumers need to run in an EventMachine 'run' block.  Try wrapping them inside the evented consumer manager." unless EM.reactor_running?

          queue = channel.queue("queue_#{self.object_id}")
          exchange = channel.fanout(fanout_name_for(destination), @options)
          ack = @options[:ack]

          queue.bind(exchange).subscribe(@options) do |header, msg|
            RosettaQueue.logger.info("Receiving from #{destination} :: #{msg}")
            message_handler.handle_message(msg)
            header.ack if ack
          end
        end

        def receive_once(destination, opts={})
          raise AdapterException, "Consumers need to run in an EventMachine 'run' block. (e.g., EM.run { RosettaQueue::Consumer.receive }" unless EM.reactor_running?

          queue = channel.queue("queue_#{self.object_id}")
          exchange = channel.fanout(fanout_name_for(destination), opts)
          ack = @options[:ack]

          queue.bind(exchange).pop(opts) do |header, msg|
            RosettaQueue.logger.info("Receiving from #{destination} :: #{msg}")
            header.ack if ack
            yield Filters.process_receiving(msg)
          end
        end

      end
    end
  end
end
