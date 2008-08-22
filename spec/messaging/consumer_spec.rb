require File.dirname(__FILE__) + '/../spec_helper'

module Messaging
  describe Consumer do
  
    before(:each) do
      @msg      = mock("Stomp::Message", "headers" => "foo", "body" => "bar")
      @stomp    = mock("Stomp::Connection", :subscribe => true, :unsubscribe => true, :disconnect => true, 
                                            :receive => @msg, :ack => true)
      Adapter.stub!(:instance).and_return(@stomp)
      @gateway  = TestConsumer.new
      @options  = {:persistent => false, :ack=>"client"}
    end
  
    describe "consuming continuously" do
    
      it_should_behave_like "a messaging gateway object"
    
      describe ".on_message" do
  
        def do_process
          @gateway.receive
          @gateway.disconnect
        end
      
        describe "method not defined on child class" do
  
          before do
            @gateway = TestConsumerWithoutOnMessage.new
          end
  
          it "should raise exception if not defined on child class" do
            during_process { @gateway.should_receive(:on_message).once.and_raise(CallbackNotImplemented) }
          end
  
        end
  
        describe "method defined on child class" do
  
          before(:each) do
            @gateway = TestConsumer.new
          end
  
          it "should subscribe to queue" do
            pending
            during_process { @stomp.should_receive("subscribe") }
          end
        
          it "should receive messages on queue" do
            pending
            during_process { @stomp.should_receive("receive") }
          end
          
          it "should pass message body to on_message callback" do
            pending
            during_process { @cons.should_receive("on_message")  }
          end
        end
      end
    end

    describe "consuming once" do
      
      def do_process
        Consumer.receive(:test_queue, {:persistent => false})
      end
      
      describe ".listen" do
      
        it "should subscribe to queue" do
          during_process { @stomp.should_receive("subscribe") }
        end
      
        # not sure why message received is nil
        it "should receive messages on queue" do
          pending
          during_process { @stomp.should_receive("receive") }
        end

        it "should return a message received" do
          Consumer.receive(:test_queue, {:persistent => false}).should == @msg.body
        end

      end
    end
  end
end