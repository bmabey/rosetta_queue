require File.dirname(__FILE__) + '/../spec_helper'

module Messaging
  describe Consumer do
  
    before(:each) do
      @msg            = mock("Stomp::Message", "headers" => "foo", "body" => "bar")
      @stomp_adapter  = mock("StompAdapter", :subscribe => true, :unsubscribe => true, :disconnect => true, :receive => @msg, :ack => true)
      Adapter.stub!(:instance).and_return(@stomp_adapter)
      @consumer = Consumer.new(@message_handler = TestConsumer.new)
      @options  = {:persistent => false, :ack=>"client"}
    end
  
    describe "consuming continuously" do
    
      it_should_behave_like "a messaging gateway object"
    
      describe ".on_message" do
  
        def do_process
          @consumer.receive
        end

        describe ".receive" do
  
          it "should subscribe to queue" do
            during_process { @stomp_adapter.should_receive("subscribe") }
          end
        
          it "should receive messages on queue" do
            during_process { @stomp_adapter.should_receive("receive") }
          end
          
          it "should pass message body to on_message callback" do
            during_process { @stomp_adapter.should_receive("receive").with(@message_handler) }
          end
        end
      end
    end

    describe "consuming once" do
      
      def do_process
        Consumer.receive(:test_queue, {:persistent => false})
      end
      
      describe ".receive" do
      
        it "should subscribe to queue" do
          during_process { @stomp_adapter.should_receive("subscribe") }
        end
      
        # not sure why message received is nil
        it "should receive messages on queue" do
          pending
          during_process { @stomp_adapter.should_receive("receive") }
        end

        it "should return a message received" do
          Consumer.receive(:test_queue, {:persistent => false}).should == @msg.body
        end

      end
    end
  end
end