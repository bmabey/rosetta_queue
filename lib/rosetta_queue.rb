$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__))) unless $LOAD_PATH.include?(File.expand_path(File.dirname(__FILE__)))

require 'core_ext'
require 'rosetta_queue/adapter'
require 'rosetta_queue/base'
require 'rosetta_queue/consumer'
require 'rosetta_queue/destinations'
require 'rosetta_queue/exceptions'
require 'rosetta_queue/filters'
require 'rosetta_queue/logger'
require 'rosetta_queue/message_handler'
require 'rosetta_queue/producer'

if defined?(Rails)
  RosettaQueue.logger = RosettaQueue::Logger.new(File.join(Rails.root, 'log', 'rosetta_queue.log'))
  require('rosetta_queue/spec_helpers') if Rails.env == "test"
end
