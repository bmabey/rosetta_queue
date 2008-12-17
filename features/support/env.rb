require 'cucumber/cli'
require File.join(File.dirname(__FILE__), "/../../spec", "spec_helper.rb")

World do |w|
  w.extend(RosettaQueue::StoryHelpers)
  
end
