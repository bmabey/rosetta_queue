require File.dirname(__FILE__) + '/../spec_helper'

module Messaging
  describe Producer do

    before(:all) do
      @stomp    = mock("Stomp::Connection", :subscribe => nil, :send => nil, :receive => @msg, :ack => nil)
      Stomp::Connection.stub!(:open).and_return(@stomp)
      @gateway  = TestProducer.new
      @headers  = {:persistent => false}
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
          during_process { @stomp.should_receive("send").with("/queue/test_queue", @msg, @headers) }
        end

      end
    end
  end
end