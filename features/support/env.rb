# ENV['EVENTMACHINE_LIBRARY'] = "pure_ruby"
ENV["MESSAGING_ENV"] = "test"
require File.dirname(__FILE__) + '/../../init.rb'
require 'spec/expectations'

require 'rosetta_queue/spec_helpers'
RosettaQueue.logger = RosettaQueue::Logger.new(File.join(File.dirname(__FILE__), '../../log', 'rosetta_queue.log'))

World do |w|
  w.extend(RosettaQueue::StoryHelpers)
end

AMQP.logging = false
# Thread.new {EM.run{}}
