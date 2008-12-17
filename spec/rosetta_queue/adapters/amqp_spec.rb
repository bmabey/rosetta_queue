require File.dirname(__FILE__) + '/../../spec_helper'
require File.dirname(__FILE__) + '/shared_adapter_behavior'

module RosettaQueue::Gateway

  describe AmqpAdapter do

    before(:each) do
      @msg = "Hello World!"
      AMQP.stub!(:connect).and_return(@conn = mock("AMQP::Client"))
      @queue = mock("MQ::Queue", :pop => @msg, :publish => true)
      @channel = mock("MQ", :queue => @queue)
      @queue.stub!(:subscribe).and_yield(@msg)
      MQ.stub!(:new).and_return(@channel)
      @adapter = AmqpAdapter.new("foo", "bar", "localhost")
      @handler = mock("handler", :on_message => true, :destination => :foo)
      EM.stub!(:run).and_yield
      EM.stub!(:add_timer)
    end

    it_should_behave_like "an adapter"

    describe "#receive_once" do

      def do_receiving_once
        @adapter.receive_once("/queue/foo", {:durable => false})
      end
      
      it "should return the message from the connection" do
        @adapter.receive_once("/queue/foo", {:durable => false}).should == @msg
      end

      it "should subscribe to queue" do
        when_receiving_once {
          @queue.should_receive(:pop)
        }
      end

    end

    describe "#receive_with" do

      before(:each) do
        @handler = mock("handler", :on_message => true, :destination => :foo)
      end

      it "should subscribe to queue defined by the class with the options defined on the class" do
        when_receiving_with_handler {
          @queue.should_receive(:subscribe).and_yield(@msg)
        }
      end
      
    end
    
    describe "#send_message" do

      it "should instantiate queue" do
        when_publishing {
          @channel.should_receive(:queue).and_return(@queue)
        }
      end

      it "should publish message to queue" do
        when_publishing {
          @channel.queue.should_receive(:publish).with('message')
        }
      end

      it "should stop event loop" do
        when_publishing {
          EM.should_receive(:add_timer).with(1)
        }
      end

    end
  end
end