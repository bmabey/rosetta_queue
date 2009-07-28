require 'rubygems'
require File.dirname(__FILE__) + '/../init.rb'

RosettaQueue::Adapter.define do |a|
  a.user      = "rosetta"
  a.password  = "password"
  a.host      = "localhost"
  a.type      = "amqp_synch"
end

RosettaQueue::Destinations.define do |dest|
  dest.map :foo, "queue.foo"
end  

RosettaQueue::Producer.publish(:foo, "hello there")
