require File.dirname(__FILE__) + '/../spec_helper'

module Messaging
  describe Consumer do

    before(:all) do
      @msg      = mock("Stomp::Message", "headers" => "foo", "body" => "bar")
      @stomp    = mock("Stomp::Connection", :subscribe => nil, :receive => @msg, :ack => nil)
      Stomp::Connection.stub!(:open).and_return(@stomp)
      @gateway  = TestConsumer.new
      @headers  = {:persistent => false, :ack=>"client"}
    end

    it_should_behave_like "a messaging gateway object"

    # describe "stomp connection" do
    # 
    #   describe ".listen" do
    # 
    #     def do_process
    #       @cons.listen
    #     end
    # 
    #     it "should subscribe to queue" do
    #       during_process { @stomp.should_receive("subscribe") }
    #     end
    #     
    #     it "should receive messages on queue" do
    #       during_process { @stomp.should_receive("receive") }
    #     end
    # 
    #     it "should pass message body to on_message callback" do
    #       during_process { @cons.should_receive("on_message")  }
    #     end
    #   end
    # end
  end
end