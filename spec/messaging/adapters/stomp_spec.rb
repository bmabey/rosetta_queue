require File.dirname(__FILE__) + '/../../spec_helper'


module Messaging
  module Gateway

    describe StompAdapter do

      before(:each) do
        @conn = mock("Stomp::Connection", :ack => true, :send => true)
        ::Stomp::Connection.stub!(:open).and_return(@conn)    
        @stomp_adapter = StompAdapter.new("user", "password", "host", "port")
      end
      
      describe "#send_message" do
        it "should delegate to the connection" do
          # need this hack since the stomp client overrides #send
          def @connection.send(*args)
            @args = args
          end
          def @connection.sent_args ; @args  end
    
          # when
          @stomp_adapter.send_message('queue', 'message', 'options')
          # then
          @connection.sent_args.should == ['queue', 'message', 'options']
        end
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