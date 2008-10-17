require File.dirname(__FILE__) + '/../../spec_helper'

module RosettaQueue
  module Gateway
  
    describe FakeAdapter do

      describe "#queues" do
        it "should return all the queues that messages were delivered to" do
          # given
          adapter = FakeAdapter.new
          adapter.send_message('queue 1', 'message 1', 'headers 1')
          adapter.send_message('queue 2', 'message 2', 'headers 2')
          # then
          adapter.queues.should == ['queue 1', 'queue 2']
        end
      end
      
      describe "#messages_sent_to" do
        it "should return the message bodies that were delivered to the specified queue" do
          # given
          adapter = FakeAdapter.new
          adapter.send_message('queue 1', 'message 1', 'headers 1')
          adapter.send_message('queue 2', 'message 2', 'headers 2')
          adapter.send_message('queue 1', 'message 3', 'headers 3')
          # when
          results = adapter.messages_sent_to('queue 1')
          # then
          results.should == ['message 1', 'message 3']
        end
        
        it "should return all the message's bodies when nil is passed in at the queue" do
          # given
          adapter = FakeAdapter.new
          adapter.send_message('queue 1', 'message 1', 'headers 1')
          adapter.send_message('queue 2', 'message 2', 'headers 2')
          # when
          results = adapter.messages_sent_to(nil)
          # then
          results.should == ['message 1', 'message 2']
        end
        
        it "should return an empty array when no messages have been delivered" do
          # given
          adapter = FakeAdapter.new
          adapter.send_message('queue 1', 'message 1', 'headers 1')
          # when
          results = adapter.messages_sent_to('queue 2')
          # then
          results.should == []
        end
        
      end

    end
  
  end

end