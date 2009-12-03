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
        @adapter = mock("adapter", :send_message => nil)
        RosettaQueue::Adapter.stub!(:instance).and_return(@adapter)
      end

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
      it "should send the message to the adapter along with the options" do
        # expect
        @adapter.should_receive(:send_message).with("/queue/test_queue", "Hello World!", {:persistent => true})
        # when
        Producer.publish(:test_queue, "Hello World!", {:persistent => true})
      end

      it "delegates exception handling to the ExceptionHandler for :publishing" do
        ExceptionHandler.should_receive(:handle).with(:publishing, anything)
        Producer.publish(:test_queue, "Hello World!", {:persistent => true})
      end

      it "wraps the publishing in an ExceptionHandler::handler block" do
        @adapter.should_not_receive(:send_message)
        ExceptionHandler.stub!(:handle).and_return("I was wrapped")
        Producer.publish(:test_queue, "m").should == "I was wrapped"
      end

      it "provides additional message information to the ExceptionHandler" do
        ExceptionHandler.should_receive(:handle).with do |_, hash_proc|
          hash_proc.call.should == {
          :message => "message",
          :action => :publishing,
          :destination => :test_queue,
          :options => {:persistent => true}}
        end
        Producer.publish(:test_queue, "message", {:persistent => true})
      end

    end

  end
end
