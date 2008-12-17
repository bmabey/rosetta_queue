require File.dirname(__FILE__) + '/../../spec_helper'
require File.dirname(__FILE__) + '/shared_manager_behavior'

module RosettaQueue

  describe EventedManager do

    before(:each) do
      Stomp::Connection.stub!(:open).and_return(nil)
      @consumer = mock("test_consumer_1", :receive => true, 
                                          :connection => mock("AmqpAdapter", :subscribe => true, :unsubscribe => nil, :disconnect => nil),
                                          :unsubscribe => true, :disconnect => true)
      Consumer.stub!(:new).and_return(@consumer)
      @manager = EventedManager.new
      @manager.add(@message_handler = mock("message_handler", :destination => "/queue/foo", :option_hash => {}))
    end

    it_should_behave_like "a consumer manager"

    describe "running" do

      before(:each) do
        EM.stub!(:run).and_yield
      end

      describe "starting" do
        
        def do_process
          @manager.start
        end

        it "should start consumers" do
          during_process {
            @manager.consumers.each_value { |cons| cons.should_receive(:receive) }
          }
        end
        
      end

      describe "stopping" do

        def do_process
          @manager.stop
        end
        
        it "should stop consumers" do
          during_process {
            EM.should_receive(:stop)
          }
        end
        
      end

    end
  end
end