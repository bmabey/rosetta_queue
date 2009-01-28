require File.dirname(__FILE__) + '/../../spec_helper'
require File.dirname(__FILE__) + '/shared_adapter_behavior'
require 'rosetta_queue/adapters/stomp'

module RosettaQueue
  module Gateway

    describe StompAdapter do

      before(:each) do
        @msg = "Hello World!"
        @handler = mock('handler', :destination => :foo, :options_hash => {:persistent => false, :ack => "client"}, :on_message => "")
        @msg_obj = mock("message", :body => @msg, :headers => {"message-id" => 2})
        @conn = mock("Stomp::Connection", :ack => true, :send => true, :subscribe => true, :receive => @msg_obj, :unsubscribe => true, :disconnect => true)
        ::Stomp::Connection.stub!(:open).and_return(@conn)
        @adapter = StompAdapter.new("user", "password", "host", "port")
        @adapter.stub!(:running).and_yield
      end

      it_should_behave_like "an adapter"
      
      describe "#send_message" do
        it "should delegate to the connection" do
          # need this hack since the stomp client overrides #send
          def @conn.send(*args)
            @args = args
          end
          def @conn.sent_args ; @args  end
    
          after_publishing {
            @conn.sent_args.should == ['queue', 'message', 'options']          
          }
        end
      end

      describe "#receive_once" do

        def do_receiving_once
          @adapter.receive_once("/queue/foo", {:persistent => false})
        end
            
        it "should subscribe to queue" do
          when_receiving_once { 
            @conn.should_receive("subscribe").with("/queue/foo", {:persistent => false}) 
          }
        end
        
        it "should unsubscribe from queue" do
          when_receiving_once { 
            @conn.should_receive("unsubscribe").with("/queue/foo") 
          }
        end
      end

      describe "#receive_with" do

        it "should subscribe to queue defined by the class with the options defined on the class" do
          when_receiving_with_handler {
            @conn.should_receive("subscribe").with('/queue/foo', :persistent => false, :ack => "client")
          }
        end

        it "should acknowledge client" do
          when_receiving_with_handler {
            @conn.should_receive(:ack)
          }
        end          
      
        describe "no ack" do

          before(:each) do
            @handler = mock('handler', :destination => :foo, :options_hash => {:persistent => false}, :on_message => "")
          end

          it "should not acknowledge client" do
            when_receiving_with_handler {
              @conn.should_not_receive(:ack)              
            }
          end          

        end      
      end
      
      describe "disconnect" do
        
        def do_disconnecting
          @adapter.disconnect(@handler)
        end

        it "should unsubscribe connection" do
          when_disconnecting {
            @conn.should_receive("unsubscribe").with("/queue/foo")          
          }
        end

        it "should disconnect connection" do
          when_disconnecting {
            @conn.should_receive("disconnect")
          }
        end
                
      end      
    end
  end
end
