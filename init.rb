require 'rubygems'
require 'activesupport' #TODO: remove this dependency!
require 'logger'

%w[rosetta_queue].each do |file|
  require File.join(File.dirname(__FILE__), "lib", file)
end

if defined?(Rails)
  RosettaQueue.logger = RosettaQueue::Logger.new(File.join(Rails.root, 'log', 'rosetta_queue.log'))
  RosettaQueue.load_spec_helpers if Rails.env != "production"
end
