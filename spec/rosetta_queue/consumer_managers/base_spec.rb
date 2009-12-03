require File.dirname(__FILE__) + '/../../spec_helper'

module RosettaQueue
  describe BaseManager do
    
    describe "#add" do
      it "allows adding a handler" do
        BaseManager.new.add(Object.new)
      end
      
      it "wraps the handler with a consumer and stores it" do
        handler = Object.new
        Consumer.should_receive(:new).with(handler)
        BaseManager.new.add(handler)
      end
      
      describe "storing the consumer" do
        it "uses the class name as the key by default" do
          handler = Object.new
          manager = BaseManager.new
          manager.add(handler)
          manager.consumers.keys.should == [:object]
        end
        
        it "allows overriding the key name for cases where you have multiple instances of the same handler class" do
          handler = Object.new
          manager = BaseManager.new
          manager.add(handler, :object_1)
          manager.add(handler, :object_2)
          manager.consumers.keys.should =~ [:object_1, :object_2]
        end
      end
    end
  end

end
