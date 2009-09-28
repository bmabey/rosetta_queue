require File.dirname(__FILE__) + '/../spec_helper'

module RosettaQueue

  class SimplerHandler
    include MessageHandler
    subscribes_to :test_queue
    options :my => 'options'

    def on_message(filtered_message)
    end
  end

  describe MessageHandler do
    before(:each) do
      Filters.stub!(:safe_process_receiving => 'safely processed message')
      @message_handler = SimplerHandler.new
      Destinations.stub!(:lookup).and_return("/queue/test_queue")
      ExceptionHandler.stub!(:handle).and_yield
    end

    describe "#handle_message" do
      it "calls the ExceptionHandler for :publishing" do
        ExceptionHandler.should_receive(:handle).with(:publishing, anything)
        @message_handler.handle_message("foo")
      end

      it "filters the message" do
        Filters.should_receive(:process_receiving).with("hello")
        @message_handler.handle_message("hello")
      end

      it "provides additional message information to the ExceptionHandler" do
        ExceptionHandler.should_receive(:handle).with do |_, hash_proc|
          hash_proc.call.should == {
          :message => "safely processed message",
          :action => :consuming,
          :destination => :test_queue,
          :options => {:my => 'options'}}
        end
          @message_handler.handle_message("message")
      end

    end

  end
end
