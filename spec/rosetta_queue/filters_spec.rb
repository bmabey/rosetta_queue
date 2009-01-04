require File.dirname(__FILE__) + '/../spec_helper'

module RosettaQueue
  
  describe Filters do
    
    after(:each) do
      Filters.reset
    end
    
    describe "#process_receiving" do
      it "should process the passed in message with the defined receiving filter" do
        Filters.define do |f| 
          f.receiving {|message| "Foo #{message}"}
        end
        
        Filters.process_receiving("Bar").should == "Foo Bar"
      end
      
      it "should return the same message when no filter is defined" do
        Filters.process_receiving("Bar").should == "Bar"
      end
    end
    
    
    describe "#process_sending" do
      it "should process the passed in message with the defined sending filter" do
        Filters.define do |f| 
          f.sending {|message| "Foo #{message}"}
        end
        
        Filters.process_sending("Bar").should == "Foo Bar"
      end
      
      it "should return the same message when no filter is defined" do
        Filters.process_sending("Bar").should == "Bar"
      end      
    end
    
    
    
  end
  
end
