require File.dirname(__FILE__) + '/../spec_helper.rb'

module Messaging
  describe SubscriptionManager do

    before(:each) do
      Stomp::Connection.stub!(:open).and_return(nil)
      @a_gateway = mock(TestConsumer.new, :unsubscribe => nil, :disconnect => nil)
      @a_gateway.stub!(:listen)
      @manager = SubscriptionManager.new
      @manager.add(:mock1, @a_gateway)
    end

    def do_process
      @manager.add(:mock2, @a_gateway)      
    end

    it "should allow user to add new gateway subscriptions" do
      after_process {@manager.subscriptions.size.should == 2 }
    end

    describe "threading" do

      before do
        @manager.stub!(:join_threads)
        @manager.stub!(:monitor_threads)
        @thread = mock(Thread, :kill => nil)
      end

      def do_process
        @manager.start        
      end

      it "should load subscriptions into threads on start" do
        during_process {Thread.should_receive(:new).with(:mock1, @a_gateway).and_return(@thread)}
      end

      describe "shutting down" do

        def do_process
          @manager.start
          @manager.stop
        end

        it "should shut threaded subscriptions down on stop" do
          during_process {Thread.should_receive(:new).with(:mock1, @a_gateway).and_return(@thread)}
        end
      end
    end
  end
end