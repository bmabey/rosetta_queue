module RosettaQueue

  describe "a consumer manager", :shared => true do

    def do_process
      @manager.start        
    end
    
    describe ".add" do

      def do_process
        @manager.add(@message_handler)
      end

      it "should load message_handler into consumer" do
        during_process { Consumer.should_receive(:new).with(@message_handler) }
      end

      it "should allow user to add new consumers" do
        @manager.consumers.size.should == 1
      end

    end

  end
end