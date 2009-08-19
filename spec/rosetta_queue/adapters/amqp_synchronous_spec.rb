require File.dirname(__FILE__) + '/../../spec_helper'
require File.dirname(__FILE__) + '/shared_adapter_behavior'
require File.dirname(__FILE__) + '/shared_fanout_behavior'

begin
  require 'rosetta_queue/adapters/amqp_synch'
rescue LoadError => ex
  if ex.message =~ /bunny/i
    warn "--WARNING-- Skipping all of tha AmqpSynchAdapter code examples since bunny is not present. Install bunny if you need to be testing this adapter!"
  else
    raise ex
  end
end

if defined? Bunny

module RosettaQueue::Gateway

  describe "an exchange", :shared => true do

    describe "#do_exchange" do

      it "should filter the message and forward it to the handler" do
        when_receiving_exchange {
          ::RosettaQueue::Filters.should_receive(:process_receiving).with(@msg).and_return("Filtered Message")
          @handler.should_receive(:on_message).with("Filtered Message")
        }
      end
    end
  end

  describe "AmqpSynch adapter and components" do

    before(:each) do
      RosettaQueue.logger.stub!(:info)
      @msg = "Hello World!"
      @adapter = AmqpSynchAdapter.new({:user => "foo", :password => "bar", :host => "localhost"})
      @handler = mock("handler", :on_message => true, :destination => :foo, :options_hash => {:durable => true})
    end

    describe AmqpSynchAdapter do

      before(:each) do
        @exchange_strategy = mock('DirectExchange', :receive_once => @msg, :receive => @msg, :send_message => true)
        SynchExchange::DirectExchange.stub!(:new).and_return(@exchange_strategy)
      end

      it_should_behave_like "an adapter"

      describe "#receive_once" do

        def do_receiving_once
          @adapter.receive_once("queue.foo", {:durable => false})
        end

        it "should pass destination and options to exchange strategy" do
          when_receiving_once {
            @exchange_strategy.should_receive(:receive_once).with("queue.foo")
          }
        end

      end

      describe "#receive_with" do

        def do_receiving_with_handler
          @adapter.receive_with(@handler)
        end

        before(:each) do
          @handler = mock("handler", :on_message => true, :destination => :foo, :options_hash => {:durable => true })
        end

        it "should pass message handler to exchange strategy" do
          when_receiving_with_handler {
            @exchange_strategy.should_receive(:receive).with("foo", @handler)
          }
        end

      end

      describe "#send_message" do

        it "should pass message handler to exchange strategy" do
          when_publishing {
            @exchange_strategy.should_receive(:publish).with('queue', 'message')
          }
        end

      end
    end


    describe SynchExchange::DirectExchange do

      before(:each) do
        @queue = mock("Bunny::Queue", :pop => @msg, :publish => true, :unsubscribe => true)
        Bunny.stub!(:new).and_return(@conn = mock("Bunny::Client", :queue => @queue, :exchange => @exchange, :status => :connected))
        @queue.stub!(:subscribe).and_yield(@msg)
        @handler = mock("handler", :on_message => true, :destination => :foo)
        @exchange = SynchExchange::DirectExchange.new({:user => 'user', :password => 'pass', :host => 'host', :opts => {:vhost => "foo"}})
      end


      def do_receiving_exchange
        @exchange.receive("queue.foo", @handler)
      end

      it_should_behave_like "an exchange"

      describe "#receive_once" do

        def do_receiving_single_exchange
          @exchange.receive_once("queue.foo") { |msg| }

        end

        it "should return the message from the connection" do
          @exchange.receive_once("queue.foo") do |msg|
              msg.should == @msg
          end
        end

        it "should subscribe to queue" do
          when_receiving_single_exchange {
            @queue.should_receive(:pop)
          }
        end

      end

      describe "#receive" do

        it "should subscribe to queue" do
          when_receiving_exchange {
            @queue.should_receive(:subscribe).and_yield(@msg)
          }
        end

      end


      describe "#publish" do

        def do_publishing
          @exchange.publish('queue.foo', 'message')
        end

        it "should instantiate queue" do
          when_publishing {
            @conn.should_receive(:queue).and_return(@queue)
          }
        end

        it "should publish message to queue" do
          when_publishing {
            @conn.queue.should_receive(:publish).with("message", {})
          }
        end

      end

    end


    describe SynchExchange::FanoutExchange do

      before(:each) do
        @exchange = SynchExchange::FanoutExchange.new({:user => 'user', :password => 'pass', :host => 'host', :opts => {:vhost => 'foo'}})
        @queue = mock("Bunny::Queue", :pop => @msg, :bind => @bound_queue = mock("Bunny::Queue", :pop => @msg), :publish => true, :unbind => true)
        Bunny.stub!(:new).and_return(@conn = mock("Bunny::Client", :queue => @queue, :exchange => @exchange, :status => :connected))
        @queue.stub!(:subscribe).and_yield(@msg)
        @handler = mock("handler", :on_message => true, :destination => :foo, :options => {:durable => false})
      end

      def do_receiving_exchange
        @exchange.receive("topic.foo", @handler)
      end

      it_should_behave_like "an exchange"

      describe "#receive_once" do

        def do_receiving_exchange
          @exchange.receive_once("topic.foo") { |msg| }
        end

        it_should_behave_like "a fanout exchange adapter"

        it "should return the message from the connection" do
          @exchange.receive_once("topic.foo") do |msg|
            msg.should == @msg
          end
        end

        it "should subscribe to queue" do
          when_receiving_exchange {
            @queue.should_receive(:pop)
          }
        end

        it "should unbind queue from exchange" do
          pending
          when_receiving_single_exchange {
            @queue.should_receive(:unbind)
          }
        end

      end

      describe "#receive" do

        it_should_behave_like "a fanout exchange adapter"

        it "should forward the message body onto the handler" do
          when_receiving_exchange {
            @handler.should_receive(:on_message).with("Hello World!")
          }
        end

        it "should subscribe to queue" do
          when_receiving_exchange {
            @queue.should_receive(:subscribe).and_yield(@msg)
          }
        end

      end

      # describe "#publish_to_exchange" do
      #
      #   def do_publishing
      #     @exchange.publish_to_exchange('/queue/foo', 'message', {:durable => false})
      #   end
      #
      #   it "should instantiate queue" do
      #     when_publishing {
      #       @channel.should_receive(:queue).and_return(@queue)
      #     }
      #   end
      #
      #   it "should publish message to queue" do
      #     when_publishing {
      #       @channel.queue.should_receive(:publish).with('message')
      #     }
      #   end
      #
      #   it "should stop event loop" do
      #     when_publishing {
      #       EM.should_receive(:stop_event_loop)
      #     }
      #   end
      # end

      describe SynchExchange::AmqpAdapterProxy do

        before(:each) do
          @queue = mock("Queue", :ack => nil)
          @proxy = SynchExchange::AmqpAdapterProxy.new(@queue)
        end

        context "#ack" do
          
          it "should delegate to AMQP queue object" do
            # expect
            @queue.should_receive(:ack)

            # when
            @proxy.ack
          end
          
        end
      end

    end
  end
end

end # for Guard up top to prevent this spec from running if Bunny not loaded from amqp_synch
