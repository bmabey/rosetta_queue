require 'bunny'
require File.expand_path(File.dirname(__FILE__) + "/amqp.rb")

module RosettaQueue
  module Gateway

    # This AMQP adapter utilizes the synchronous AMPQ client 'Bunny'
    # by celldee (http://github.com/celldee/bunny)
    class AmqpSynchAdapter < Amqp
      private

      def exchange_strategy_for(destination, options)
        case destination
        when /^fanout\./
          @exchange ||= SynchExchange::FanoutExchange.new(@adapter_settings, options)
        when /^topic\./
          raise "Sorry.  RosettaQueue can not process AMQP topics yet"
        when /^queue\./
          @exchange ||= SynchExchange::DirectExchange.new(@adapter_settings, options)
        else
          @exchange ||= SynchExchange::DirectExchange.new(@adapter_settings, options)
        end
      end
    end 

    module SynchExchange

      class BaseExchange

        def initialize(adapter_settings, options={})
          @adapter_settings, @options = adapter_settings, options
        end

        def delete(destination)
          conn.queue(destination).delete(@options)
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

        def process_message(queue, msg)
          if @ack[:manual_ack]
            @message_handler.adapter_proxy = queue
            @message_handler.on_message(Filters.process_receiving(msg))
          elsif @ack[:automatic_ack]
            @message_handler.on_message(Filters.process_receiving(msg))
            queue.ack
          else 
            @message_handler.on_message(Filters.process_receiving(msg))
          end 
        end 
      end

      class DirectExchange < BaseExchange

        def publish(destination, message, options={})
          RosettaQueue.logger.info("Publishing to #{destination} :: #{message}")
          queue = conn.queue(destination, options)
          queue.publish(message, options)
          queue.unsubscribe
        end      

        def receive(destination, message_handler)
          queue = conn.queue(destination, @options)
          @ack = {:automatic_ack => @options[:ack], :manual_ack => @options[:manual_ack]}
          @message_handler = message_handler
          queue.subscribe(@options) do |msg|
            RosettaQueue.logger.info("Receiving from #{destination} :: #{msg}")
            process_message(queue, msg)
          end 
        end

        def receive_once(destination)
          queue = conn.queue(destination, @options)
          ack = @options[:ack]
          msg = queue.pop(@options)
          RosettaQueue.logger.info("Receiving from #{destination} :: #{msg}")
          queue.ack if ack
          yield Filters.process_receiving(msg)
        end

      end

      class FanoutExchange < BaseExchange
        include Fanout
        
        def publish(destination, message, options={})
          exchange = conn.exchange(fanout_name_for(destination), options.merge({:type => :fanout}))
          exchange.publish(message, options)
          RosettaQueue.logger.info("Publishing to fanout #{destination} :: #{message}")
        end      

        def receive(destination, message_handler)
          queue = conn.queue("queue_#{self.object_id}", @options)
          exchange = conn.exchange(fanout_name_for(destination), @options.merge({:type => :fanout}))
          queue.bind(exchange)
          @ack = {:automatic_ack => @options[:ack], :manual_ack => @options[:manual_ack]}
          @message_handler = message_handler
          msg = queue.subscribe(@options) do |msg|
            RosettaQueue.logger.info("Receiving from #{destination} :: #{msg}")
            process_message(queue, msg)
          end        
        end

        def receive_once(destination, options={})
          queue = conn.queue("queue_#{self.object_id}", options)
          exchange = conn.exchange(fanout_name_for(destination), options.merge({:type => :fanout}))
          queue.bind(exchange)
          ack = @options[:ack]
          msg = queue.pop(@options)
          RosettaQueue.logger.info("Receiving from #{destination} :: #{msg}")
          queue.ack if ack
          yield Filters.process_receiving(msg)
        end

      end 

      class AmqpAdapterProxy

        def initialize(queue)
          @queue = queue
        end 

        def ack
          @queue.ack
        end 

      end 
    end 

  end
end
