ENV["MESSAGING_ENV"] = "test"

require 'rubygems'
require 'spec'
require 'ruby-debug'

$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'rosetta_queue'
require 'rosetta_queue/adapters/null'
require 'rosetta_queue/adapters/fake'
require 'rosetta_queue/adapters/stomp'
require 'rosetta_queue/adapters/amqp'
require 'rosetta_queue/spec_helpers'
require 'rosetta_queue/consumer_managers/base'
require 'rosetta_queue/consumer_managers/evented'
require 'rosetta_queue/consumer_managers/threaded'
require File.dirname(__FILE__) + '/rosetta_queue/shared_messaging_behavior.rb'


class NullLogger
  def info(*args);  end
  def debug(*args); end
  def fatal(*args); end
  def error(*args); end
  def warn(*args);  end
end

RosettaQueue.logger = NullLogger.new

alias :running :lambda

[:process, :receiving_with_handler, :receiving_once, :publishing, :disconnecting, :receiving_single_exchange, :receiving_exchange, :receiving].each do |action|
  eval %Q{
    def before_#{action}
      yield
      do_#{action}
    end
    alias during_#{action} before_#{action}
    alias when_#{action} before_#{action}
    def after_#{action}
      do_#{action}
      yield
    end
  }
end
