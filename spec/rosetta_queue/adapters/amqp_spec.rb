require File.dirname(__FILE__) + '/../../spec_helper'
require File.dirname(__FILE__) + '/shared_adapter_behavior'
require File.dirname(__FILE__) + '/shared_fanout_behavior'
require 'rosetta_queue/adapters/amqp'

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

  describe "Amqp adapter and components" do

    before(:each) do
      RosettaQueue.logger.stub!(:info)
      @msg = "Hello World!"
      @adapter = AmqpAdapter.new("foo", "bar", "localhost")
      @handler = mock("handler", :on_message => true, :destination => :foo)
    end
    
    describe AmqpAdapter do

      before(:each) do
        @exchange_strategy = mock('DirectExchange', :do_single_exchange => @msg, :do_exchange => @msg, :send_message => true)
        DirectExchange.stub!(:new).and_return(@exchange_strategy)  
      end

      it_should_behave_like "an adapter"

      describe "#receive_once" do

        def do_receiving_once
          @adapter.receive_once("/queue/foo", {:durable => false})
        end
    
        it "should pass destination and options to exchange strategy" do
          when_receiving_once {
            @exchange_strategy.should_receive(:do_single_exchange).with("/queue/foo", {:durable => false})
          }
        end
    
      end
      
      describe "#receive_with" do

        def do_receiving_with_handler
          @adapter.receive_with(@handler)
        end
      
        before(:each) do
          @handler = mock("handler", :on_message => true, :destination => :foo)
        end

        it "should pass message handler to exchange strategy" do
          when_receiving_with_handler {
            @exchange_strategy.should_receive(:do_exchange).with("/queue/foo", @handler)
          }
        end

      end
      
      describe "#send_message" do    

        it "should pass message handler to exchange strategy" do
          when_publishing {
            @exchange_strategy.should_receive(:publish_to_exchange).with('queue', 'message', 'options')
          }
        end
    
      end
    end


    describe DirectExchange do
    
      before(:each) do
        AMQP.stub!(:connect).and_return(@conn = mock("AMQP::Client"))    
        @queue = mock("MQ::Queue", :pop => @msg, :publish => true, :unsubscribe => true)
        @channel = mock("MQ", :queue => @queue)
        MQ.stub!(:new).and_return(@channel)
        @queue.stub!(:subscribe).and_yield(@msg)
        @handler = mock("handler", :on_message => true, :destination => :foo)
        EM.stub!(:run).and_yield
        EM.stub!(:stop_event_loop)
        @strategy = DirectExchange.new('user', 'pass', 'host')
      end
      
      
      def do_receiving_exchange
        @strategy.do_exchange("/queue/foo", @handler)
      end
      
      it_should_behave_like "an exchange"
      
      describe "#do_single_exchange" do
    
        def do_receiving_single_exchange
          @strategy.do_single_exchange("/queue/foo", {:durable => false})
        end
    
        it "should return the message from the connection" do
          @strategy.do_single_exchange("/queue/foo", {:durable => false}).should == @msg
        end
    
        it "should subscribe to queue" do
          when_receiving_single_exchange {
            @queue.should_receive(:pop)
          }
        end
    
        # it "should stop event loop" do
        #   pending
        #   when_receiving_single_exchange {
        #     EM.should_receive(:stop_event_loop)
        #   }
        # end
    
      end
    
      describe "#do_exchange" do

        it "should subscribe to queue" do
          when_receiving_exchange {
            @queue.should_receive(:subscribe).and_yield(@msg)
          }
        end                
  
      end
    
    
      describe "#publish_to_exchange" do
        
        before(:each) do
          EM.stub!(:reactor_running?).and_return(true)
        end
    
        def do_publishing
          @strategy.publish_to_exchange('/queue/foo', 'message', {:durable => false})
        end
    
        it "should instantiate queue" do
          when_publishing {
            @channel.should_receive(:queue).and_return(@queue)
          }
        end
        
        it "should publish message to queue" do
          when_publishing {
            @channel.queue.should_receive(:publish).with('message', {:durable => false})
          }
        end
        
        # it "should stop event loop" do
        #   when_publishing {
        #     EM.should_receive(:stop_event_loop)
        #   }
        # end
      end
    
    end
    
    
    describe FanoutExchange do
    
      before(:each) do
        AMQP.stub!(:connect).and_return(@conn = mock("AMQP::Client"))    
        @queue = mock("MQ::Queue", :pop => @msg, :bind => @bound_queue = mock("MQ::Queue", :pop => @msg), :publish => true, :unbind => true)
        @channel = mock("MQ", :queue => @queue, :fanout => 'fanout')
        MQ.stub!(:new).and_return(@channel)
        @bound_queue.stub!(:subscribe).and_yield(@msg)
        @handler = mock("handler", :on_message => true, :destination => :foo, :options => {:durable => false})
        EM.stub!(:run).and_yield
        EM.stub!(:stop_event_loop)
        @strategy = FanoutExchange.new('user', 'pass', 'host')
      end
      
      def do_receiving_exchange
        @strategy.do_exchange("/topic/foo", @handler)
      end
      
      it_should_behave_like "an exchange"
    
      describe "#do_single_exchange" do
    
        def do_receiving_exchange
          @strategy.do_single_exchange("/topic/foo")
        end
    
        it_should_behave_like "a fanout exchange adapter"
    
        it "should return the message from the connection" do
          @strategy.do_single_exchange("/topic/foo").should == @msg
        end
    
        it "should subscribe to queue" do
          when_receiving_exchange {
            @bound_queue.should_receive(:pop)
          }
        end
    
        it "should unbind queue from exchange" do
          pending
          when_receiving_single_exchange {
            @queue.should_receive(:unbind)
          }
        end
    
        it "should stop event loop" do
          pending
          when_receiving_single_exchange {
            EM.should_receive(:stop_event_loop)
          }
        end
      end
    
      describe "#do_exchange" do                  
    
        it_should_behave_like "a fanout exchange adapter"
    
        it "should forward the message body onto the handler" do
          when_receiving_exchange {
            @handler.should_receive(:on_message).with("Hello World!")
          }
        end
    
        it "should subscribe to queue" do
          when_receiving_exchange {
            @bound_queue.should_receive(:subscribe).and_yield(@msg)
          }
        end
      
      end
            
      # describe "#publish_to_exchange" do
      # 
      #   def do_publishing
      #     @strategy.publish_to_exchange('/queue/foo', 'message', {:durable => false})
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
    
    end
  end
end
