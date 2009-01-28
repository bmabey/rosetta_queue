require File.dirname(__FILE__) + '/../../spec_helper'
require 'rosetta_queue/adapters/null'

module RosettaQueue
  module Gateway


    describe NullAdapter do
      
      def null_adapter
        NullAdapter.new('user', 'password', 'host', 'port')
      end
      
      %w[disconnect receive receive_with send_message subscribe unsubscribe].each do |adapter_method|
        it "should respond to ##{adapter_method}" do
          null_adapter.should respond_to(adapter_method)
        end
      end
      
      it "should raise an error when #receive is called" do
        running { null_adapter.receive }.should raise_error
      end
      
      it "should raise an error when #receive_with is called" do
        running { null_adapter.receive_with('consumer') }.should raise_error
      end
  
    end

  end
end
