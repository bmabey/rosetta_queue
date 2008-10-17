require File.dirname(__FILE__) + '/../spec_helper'

module RosettaQueue
  
  describe Adapter do

    before(:each) do
      @stomp_adapter = mock("Gateway::StompAdapter")
      Adapter.reset
    end
    
    describe ".reset" do
      it "should clear all definitions" do
        Adapter.define { |a| a.type = "null"  }
        Adapter.instance.should be_instance_of(RosettaQueue::Gateway::NullAdapter)
        Adapter.reset
        running { Adapter.instance }.should raise_error(AdapterException)
      end
    end
    
    describe ".type=" do
      
      it "should raise error when adapter does not exist" do
        running { 
          Adapter.define do |a|
            a.type = "foo"
          end
          }.should raise_error(AdapterException)
      end
      
    end
    
    describe "adapter not type set" do
      it "should raise an error when .instance is called" do
        # given
        Adapter.define { |a|  }
        # then & when
        running { Adapter.instance }.should raise_error(AdapterException)        
      end
    end

    describe "adapter type set" do
    
      before(:each) do
        Adapter.define { |a| a.type = "null" }
      end
    
      it "should return adapter instance" do
        Adapter.instance.class.should == RosettaQueue::Gateway::NullAdapter
      end
          
    end

  end
end
