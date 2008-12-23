# ENV['EVENTMACHINE_LIBRARY'] = "pure_ruby"

require 'cucumber'
require File.join(File.dirname(__FILE__), "/../../spec", "spec_helper.rb")

World do |w|
  w.extend(RosettaQueue::StoryHelpers)
  
end

# AMQP.logging = true
# Thread.new {EM.run{}}
