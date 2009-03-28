require 'rubygems'
require File.dirname(__FILE__) + '/../init.rb'

RosettaQueue.logger = Logger.new(File.expand_path(File.dirname(__FILE__) + '/../../rosetta_queue_example_log/rosetta_queue.log'))

RosettaQueue::Adapter.define do |a|
  a.user      = "rosetta"
  a.password  = "password"
  a.host      = "localhost"
  a.type      = "amqp"
end

RosettaQueue::Destinations.define do |dest|
  dest.map :foo, "/queue/foo"
end  

EM.run do 
  RosettaQueue::Producer.publish(:foo, "hello there")
  EM.add_timer(1) {EM.stop_event_loop}
end

