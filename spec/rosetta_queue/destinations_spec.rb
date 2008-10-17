require File.dirname(__FILE__) + '/../spec_helper'

module RosettaQueue

  describe Destinations do

    before(:each) do
      Destinations.clear
    end
    
    after(:each) do
      Destinations.clear
    end
    
    it "should map destination to hash" do

      Destinations.define do |queue| 
        queue.map :test_queue, "/queue/test_queue"
      end
      
      Destinations.lookup(:test_queue).should == "/queue/test_queue"
    end
    
    it "#queue_names should return an array of the actuual queue names" do
      Destinations.define do |queue| 
        queue.map :foo, "/queue/foo"
        queue.map :bar, "/queue/bar"
      end
      
      Destinations.queue_names.should include("/queue/foo")
      Destinations.queue_names.should include("/queue/bar")
    end
  end
end