require File.dirname(__FILE__) + '/../spec_helper'

module RosettaQueue
  describe Consumer do
    
    class TestConsumer
      include MessageHandler

      subscribes_to :test_queue
      options :persistent => false, :ack => "client"

      def on_message(msg)

      end
    end

    before(:each) do
      @message  = mock("message", "headers" => "foo", "body" => "message body")
      @adapter  = mock("adpater", :subscribe => true, :unsubscribe => true, :disconnect => true, :receive_with => TestConsumer.new, 
                                  :receive_once => @message.body, :ack => true)
      Adapter.stub!(:instance).and_return(@adapter)
      Destinations.stub!(:lookup).and_return("/queue/foo")
    end
    
    it_should_behave_like "a messaging gateway object"
    
    attr_reader :adapter
    def gateway
      @gateway ||= Consumer.new(TestConsumer.new)
    end

    describe "#receive" do
      before(:each) do
        @consumer = Consumer.new( @message_handler = TestConsumer.new)
      end
            
      def when_receiving
        yield if block_given?
        @consumer.receive
      end
      
      it "should pass message handler onto the adpater with #receive" do
        when_receiving { 
          @adapter.should_receive("receive_with").with(@message_handler)
        }
      end
    end

      
    describe ".receive" do

      def when_receiving
        yield if block_given?
        Consumer.receive(:test_queue_passed_in, {:persistent => false})
      end

      it "should look up the destination" do
        when_receiving {
          Destinations.should_receive(:lookup).with(:test_queue_passed_in).and_return("/queue/foo")            
        }
      end

      it "should pass destination and options to adapter" do
        when_receiving {
          @adapter.should_receive(:receive_once).with("/queue/foo", {:persistent => false}).and_return(@message)
        }
      end

      it "should return the body of the message received" do
        Consumer.receive(:test_queue, {:persistent => false}).should == @message.body
      end
    end

  end
end