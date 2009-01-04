require File.dirname(__FILE__) + '/../init.rb'
require 'activesupport'


RosettaQueue::Destinations.define do |queue|
  queue.map :test_queue, '/queue/my_test_queue'
end

RosettaQueue::Adapter.define do |a|
  a.user      = "chris"
  a.password  = "fuzzbuzz!"
  a.host      = "localhost"
  a.type      = "stomp"
  a.port      = "61613"
end

RosettaQueue::Filters.define do |f|
  f.receiving { |message| ActiveSupport::JSON.decode(message) }
  f.sending { |hash| hash.to_json }
end

RosettaQueue::Producer.publish(:test_queue, :foo => "bar")
msg = RosettaQueue::Consumer.receive(:test_queue)

queue(:test_queue) << :foo => "Bar"


module RosettaQueue
  
  module Sugar
    def queue(queue_name)
      Queue.new(queue_name)
    end
    
  end
  
end