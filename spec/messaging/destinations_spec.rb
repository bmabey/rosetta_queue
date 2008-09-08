require File.dirname(__FILE__) + '/../spec_helper'

module Messaging

  describe Destinations do

    before do
      Destinations.define do |queue| 
        queue.map :test_queue, "/queue/test_queue"
      end
    end

    it "should map destination to hash" do
      Destinations.lookup(:test_queue).should == "/queue/test_queue"
    end
  end
end