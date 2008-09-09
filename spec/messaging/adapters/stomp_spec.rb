require File.dirname(__FILE__) + '/../../spec_helper'


module Messaging
  module Gateway

    describe StompAdapter do

      before(:each) do
        @conn = mock("Stomp::Connection", :ack => true)
        ::Stomp::Connection.stub!(:open).and_return(@conn)    
        @stomp_adapter = StompAdapter.new("user", "password", "host", "port")
      end
      
      describe "#receive" do
        it "should return the message from the connection" do
          # given
          @conn.stub!(:receive).and_return( message = mock("message", :body => "", :headers => {"message-id" => 2}))
          # when & then
          @stomp_adapter.receive.should == message
        end
      end

      describe "#receive_with" do
        
        before(:each) do
          @stomp_adapter.stub!(:running).and_yield
        end

        it "should forward the message body onto the handler" do
          # given
          handler = mock('handler')
          @conn.stub!(:receive).and_return( mock("message", :body => "Hello World!", :headers => {"message-id" => 2}))
          # expect
          handler.should_receive(:on_message).with("Hello World!")
          # when
          @stomp_adapter.receive_with(handler)
        end
      
      end
      
    end
  end
end