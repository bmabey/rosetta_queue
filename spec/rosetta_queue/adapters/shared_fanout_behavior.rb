module RosettaQueue
  module Gateway

    describe "a fanout exchange adapter", :shared => true do

      it "should discover fanout name for destation" do
        when_receiving_exchange {
          @channel.should_receive(:fanout).with('/foo').and_return(@bound_queue)
        }
      end
    
      it "should bind to fanout exchange" do
        when_receiving_exchange {
          @queue.should_receive(:bind).with('fanout').and_return(@bound_queue)
        }
      end

    end
  end
end