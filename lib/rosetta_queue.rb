$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__))) unless $LOAD_PATH.include?(File.expand_path(File.dirname(__FILE__)))

require('rosetta_queue/core_ext/string') unless defined? ActiveSupport
require('rosetta_queue/core_ext/time') unless defined? ActiveSupport

require 'rosetta_queue/adapter'
require 'rosetta_queue/consumer'
require 'rosetta_queue/destinations'
require 'rosetta_queue/exceptions'
require 'rosetta_queue/filters'
require 'rosetta_queue/logger'
require 'rosetta_queue/message_handler'
require 'rosetta_queue/exception_handler'
require 'rosetta_queue/producer'
require 'rosetta_queue/consumer_managers/base'
require 'rosetta_queue/consumer_managers/threaded'
require 'rosetta_queue/railtie' if defined?(Rails)
