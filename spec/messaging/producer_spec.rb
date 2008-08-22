require File.dirname(__FILE__) + '/../spec_helper'

module Messaging
  describe Producer do

    before(:each) do
      @msg = "foo"
      @conn = mock("Stomp::Connection", :send => nil)
      Messaging::Adapter.stub!(:instance).and_return(@conn)
      @gateway  = TestProducer.new
      @options  = {:persistent => false}
    end
    
    it_should_behave_like "a messaging gateway object"
    
    describe "stomp connection" do
    
      describe ".publish" do
    
        before(:all) do
          @msg = "foo"
        end
    
        def do_process
          @gateway.publish(@msg)
        end

        it "should publish messages to queue" do
          during_process { @conn.should_receive(:send).with("/queue/test_queue", @msg, @options) }
        end

      end

      describe "Producer.publish" do
    
        before(:all) do
          @msg = "foo"
        end
    
        def do_process
          Producer.publish(:test_queue, @msg, @options)
        end

        it "should publish messages to queue" do
          during_process { @conn.should_receive(:send).with("/queue/test_queue", @msg, @options) }
        end

      end

    end
  end
end