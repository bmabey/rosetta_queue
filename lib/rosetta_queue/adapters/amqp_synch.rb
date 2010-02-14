require 'bunny'
require File.expand_path(File.dirname(__FILE__) + "/amqp.rb")

module RosettaQueue
  module Gateway

    module SynchExchange

      class BaseExchange

        def initialize(adapter_settings, options={})
          @adapter_settings, @options = adapter_settings, options
        end

        def delete(destination, options={})
          conn.queue(destination).delete(options)
        end

        def unsubscribe
          conn.stop
        end

        protected

        def conn
          vhost = @adapter_settings[:opts][:vhost] || "/"
          @conn ||= Bunny.new( :user => @adapter_settings[:user],
                               :pass => @adapter_settings[:password],
                               :host => @adapter_settings[:host],
                               :vhost => vhost)
          @conn.start unless @conn.status == :connected
          @conn
        end

      end

      class DirectExchange < BaseExchange

        def publish(destination, message, options={})
          RosettaQueue.logger.info("Publishing to #{destination} :: #{message}")
          @queue = conn.queue(destination, options)
          @queue.publish(message, options)
        end

        def receive(destination, message_handler)
          @queue = conn.queue(destination, @options)
          @queue.subscribe(@options) do |msg|
            RosettaQueue.logger.info("Receiving from #{destination} :: #{msg[:payload]}")
            message_handler.handle_message(msg[:payload])
          end
        end

        def receive_once(destination, options = {})
          ack = options[:ack]
          @queue = conn.queue(destination, options)
          msg = @queue.pop[:payload]
          RosettaQueue.logger.info("Receiving from #{destination} :: #{msg}")
          @queue.ack if ack
          yield Filters.process_receiving(msg)
        end

      end

      class FanoutExchange < BaseExchange
        include Fanout

        def publish(destination, message, options={})
          @queue = conn.exchange(fanout_name_for(destination), options.merge({:type => :fanout}))
          @queue.publish(message, options)
          RosettaQueue.logger.info("Publishing to fanout #{destination} :: #{message}")
        end

        def receive(destination, message_handler)
          @queue = conn.queue("queue_#{self.object_id}", @options)
          exchange = conn.exchange(fanout_name_for(destination), @options.merge({:type => :fanout}))
          @queue.bind(exchange)
          @queue.subscribe(@options) do |msg|
            RosettaQueue.logger.info("Receiving from #{destination} :: #{msg[:payload]}")
            message_handler.handle_message(msg[:payload])
          end
        end

        def receive_once(destination, options={})
          ack = options[:ack]
          @queue = conn.queue("queue_#{self.object_id}", options)
          exchange = conn.exchange(fanout_name_for(destination), options.merge({:type => :fanout}))
          @queue.bind(exchange)
          msg = @queue.pop[:payload]
          RosettaQueue.logger.info("Receiving from #{destination} :: #{msg}")
          @queue.ack if ack
          yield Filters.process_receiving(msg)
        end

      end

    end
  end
end
