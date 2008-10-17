require File.dirname(__FILE__) + '/../spec_helper.rb'

module RosettaQueue
  describe ConsumerManager do

    before(:each) do
      Stomp::Connection.stub!(:open).and_return(nil)
      @consumer = mock("test_consumer_1", :receive => true, :connection => mock("StompAdapter", :subscribe => true, :unsubscribe => nil, :disconnect => nil),
                                          :unsubscribe => true, :disconnect => true)
      Consumer.stub!(:new).and_return(@consumer)
      @manager = ConsumerManager.new
      @manager.add(@message_handler = mock("message_handler", :destination => "/queue/foo", :option_hash => {}))
    end

    it "should allow user to add new consumers" do
      @manager.consumers.size.should == 1
    end

    describe ".add" do

      def do_process
        @manager.add(@message_handler)
      end

      it "should load message_handler into consumer" do
        during_process { Consumer.should_receive(:new).with(@message_handler) }
      end
      
    end

    describe "threading" do
    
      before do
        @manager.stub!(:join_threads)
        @manager.stub!(:monitor_threads)
        @thread = mock(Thread, :kill => nil)
        Thread.stub!(:new).and_return(@thread)
      end
    
      def do_process
        @manager.start        
      end
    
      it "should load subscriptions into threads on start" do
        during_process {Thread.should_receive(:new).with(:"spec/mocks/mock", @consumer).and_return(@thread)}
      end
    
      describe "shutting down" do
          
        def do_process
          @manager.start
          @manager.stop
        end
          
        it "should shut threaded subscriptions down on stop" do
          during_process do
            @consumer.should_receive(:unsubscribe)
            @consumer.should_receive(:disconnect)
            @thread.should_receive(:kill)       
          end
        end
      end
    end
  end
end