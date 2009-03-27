require 'rubygems'
$:.unshift(File.dirname(__FILE__) + '/../../lib')
require 'rosetta_queue'
require 'rosetta_queue/spec_helpers'
require 'spec/expectations'
require 'rosetta_queue/spec_helpers'
require 'amqp'

begin
  RosettaQueue.logger = RosettaQueue::Logger.new(File.join(File.dirname(__FILE__), '../../log', 'rosetta_queue.log'))
rescue Errno::ENOENT
  Kernel.warn "No log directory setup at the root of rosetta_queue. Using the null logger instead."
  class NullLogger
    def info(*args);  end
    def debug(*args); end
    def fatal(*args); end
    def error(*args); end
    def warn(*args);  end
  end

  RosettaQueue.logger = NullLogger.new
end

World do |w|
  w.extend(RosettaQueue::SpecHelpers)
end

AMQP.logging = false # true
# Thread.new {EM.run{}}
