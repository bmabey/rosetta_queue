module RosettaQueue
  module Gateway

    describe "a fanout exchange adapter", :shared => true do

#       it "should discover fanout name for destation" do
#         when_receiving_exchange {
#           @channel.should_receive(:fanout).with(@exchange).and_return(@bound_queue)
#         }
#       end

      it "should bind to fanout exchange" do
        when_receiving_exchange {
          @queue.should_receive(:bind).with(@exchange).and_return(@bound_queue)
        }
      end

    end
  end
end
