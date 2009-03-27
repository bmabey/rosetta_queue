require File.dirname(__FILE__) + '/../../spec_helper'
require File.dirname(__FILE__) + '/shared_adapter_behavior'
require 'rosetta_queue/adapters/beanstalk'

module RosettaQueue
  module Gateway

    describe BeanstalkAdapter do

      before(:each) do
        @msg = "Hello World!"
        @handler = mock('handler', :on_message => "", :destination => :foo)
        @msg_obj = mock("message", :body => @msg, :headers => {"message-id" => 2})
        @conn = mock("Beanstalk::Pool", :put => true, :reserve => @msg_obj)
        ::Beanstalk::Pool.stub!(:new).and_return(@conn)
        @adapter = BeanstalkAdapter.new("user", "password", "host", "port")
        @adapter.stub!(:running).and_yield
      end

      it_should_behave_like "an adapter"
    end
  end
end
