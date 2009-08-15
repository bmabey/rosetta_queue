require File.dirname(__FILE__) + '/../../spec_helper'
require File.dirname(__FILE__) + '/shared_manager_behavior'

module RosettaQueue
  describe ThreadedManager do

    before(:each) do
      @mutex = mock("Mutex")
      @mutex.stub!(:synchronize).and_yield
      Mutex.stub!(:new).and_return(@mutex)
      Stomp::Connection.stub!(:open).and_return(nil)
      @consumer = mock("test_consumer_1", :receive => true, :connection => mock("StompAdapter", :subscribe => true, :unsubscribe => nil, :disconnect => nil),
                                          :unsubscribe => true, :disconnect => true)
      Consumer.stub!(:new).and_return(@consumer)
      @manager = ThreadedManager.new
      @manager.add(@message_handler = mock("message_handler", :destination => "/queue/foo", :option_hash => {}))
    end

    it_should_behave_like "a consumer manager"

    describe "threading" do
    
      before do
        @manager.stub!(:join_threads)
        @manager.stub!(:monitor_threads)
        # we stub brackets because we check a Thread variable
        @thread = mock(Thread, :kill => nil, :alive? => true, :[] => false)
        Thread.stub!(:new).and_return(@thread)
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
            @consumer.should_receive(:disconnect)
            @thread.should_receive(:kill)       
          end
        end
      end
    end
  end
end