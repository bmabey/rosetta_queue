require File.join(File.dirname(__FILE__), "lib", "rosetta_queue")

if defined?(Rails)
  RosettaQueue.logger = RosettaQueue::Logger.new(File.join(Rails.root, 'log', 'rosetta_queue.log'))
  RosettaQueue.load_spec_helpers if Rails.env != "production"
end
