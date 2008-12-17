require File.dirname(__FILE__) + '/../spec_helper'

module RosettaQueue
  
  class TestProducer < Producer

    publishes_to :test_queue
    options :persistent => false

  end
  
  describe Producer do    
    
    before(:each) do
      @adapter = mock("adapter", :send_message => nil)
      RosettaQueue::Adapter.stub!(:instance).and_return(@adapter)
      @gateway  = TestProducer.new
      
      Destinations.stub!(:lookup).and_return("/queue/test_queue")
    end
    
    it_should_behave_like "a messaging gateway object"
    attr_reader :adapter, :gateway
    
    
    describe "#publish" do
      
      before(:each) do
        @adapter = mock("adpater", :send_message => nil)
        RosettaQueue::Adapter.stub!(:instance).and_return(@adapter)
      end
      
      # it "should look up the destination defined on the class" do
      #   Destinations.should_receive(:lookup).with(:test_queue).and_return("/queue/test_queue")
      #   # when
      #    @gateway.publish('some message')
      # end

      it "should publish messages to queue with the options defined in the class" do        
        # TO DO: REFACTOR #publish METHOD SO THAT YOU PASS IN MESSAGE HANDLER AS WITH CONSUMER
        pending
        # expect
        @adapter.should_receive(:send_message).with("/queue/test_queue", "Hello World!", {:persistent => false})
        # when
        @gateway.publish("Hello World!")
      end

    end
    
    describe ".publish" do
      # it "should look up the destination defined on the class" do
      #   Destinations.should_receive(:lookup).with(:test_queue).and_return("/queue/test_queue")
      #   # when
      #   Producer.publish(:test_queue, "blah")
      # end
      
      it "should send the message to the adpater along with the options" do
        # expect
        @adapter.should_receive(:send_message).with("/queue/test_queue", "Hello World!", {:persistent => true})
        # when
        Producer.publish(:test_queue, "Hello World!", {:persistent => true})
      end
    end
    
  end
end