require File.dirname(__FILE__) + '/../spec_helper'

module Messaging
  
  describe Adapter do

    before(:each) do
      @stomp = mock("Stomp::Connection")
      Gateway::StompAdapter.stub!(:open).and_return(@stomp)      
    end
    
    describe "missing adapter type" do

      before(:each) do
        Adapter.define do |a|
          a.user = "foo"
          a.password = "bar"
          a.host = "localhost"
          a.port = 61613
          a.type = ""
        end
      end
      
      it "should raise error" do
        running { Adapter.instance }.should raise_error(AdapterException)
      end
      
    end

    describe "adapter type set" do
    
      before(:each) do
        Adapter.define { |a| a.type = "stomp" }
      end
    
      it "should return adapter instance" do
        Adapter.instance.should == @stomp
      end
    
      describe "wrong adapter type" do
    
        before(:each) do
          Adapter.type = "clap"
        end
        
        it "should raise error" do
          running { Adapter.instance }.should raise_error("Adapter type does not match existing adapters!")          
        end
      end
    end

  end
end
