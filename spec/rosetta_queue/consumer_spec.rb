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

    # Wasn't being used...  We could probably have the connection manager use this in a spec to see if it quacks like a message handler
    # class TestConsumerWithoutOnMessage
    #   include MessageHandler
    # 
    #   subscribes_to :test_queue
    #   options :persistent => false, :ack => "client"
    # 
    # end
    
    
    before(:each) do
      @message            = mock("message", "headers" => "foo", "body" => "message body")
      @adapter  = mock("adpater", :subscribe => true, :unsubscribe => true, :disconnect => true, :receive => @message, :ack => true)
      Adapter.stub!(:instance).and_return(@adapter)
      Destinations.stub!(:lookup).and_return("/queue/test_queue")
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
      
      it "should look up the destination defined on the class" do
        Destinations.should_receive(:lookup).with(:test_queue).and_return("/queue/test_queue")
        when_receiving
      end
      
      
      it "should subscribe to queue defined by the class with the options defined on the class" do
        @adapter.should_receive("subscribe").with('/queue/test_queue', :persistent => false, :ack => "client") 
        when_receiving
      end
      
      it "should pass message handler onto the adpater with #receive" do
        when_receiving { @adapter.should_receive("receive").with(@message_handler) }
      end
    end

      
    describe ".receive" do

      def when_receiving
        yield if block_given?
        Consumer.receive(:test_queue_passed_in, {:persistent => false})
      end
      
      it "should look up the destination" do
        Destinations.should_receive(:lookup).with(:test_queue_passed_in).twice.and_return("/queue/test_queue")
        when_receiving
      end
    
      it "should subscribe to queue" do
        when_receiving { @adapter.should_receive("subscribe").with("/queue/test_queue", {:persistent => false}) }
      end
      
      it "should unsubscribe to queue" do
        when_receiving { @adapter.should_receive("unsubscribe").with("/queue/test_queue") }
      end

      it "should return the body of the message received" do
        Consumer.receive(:test_queue, {:persistent => false}).should == @message.body
      end
    end

  end
end