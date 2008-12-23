require 'rubygems'
require 'activesupport'
require 'logger'

%w[modules exceptions ext rosetta_queue].each do |file|
  require File.join(File.dirname(__FILE__), "lib", file)
end

if Object.const_defined?("Rails") && Rails.env != "production"
  Dir[File.join(File.dirname(__FILE__), 'lib', 'rosetta_queue', 'spec_helpers/*.rb')].each do |file|
    require file
  end
end

LOG_FILE_PATH = File.join(File.dirname(__FILE__), 'tmp', 'rosetta.log') unless defined?(LOG_FILE_PATH)
RosettaLogger = RosettaQueueLogger.new(LOG_FILE_PATH, 'daily') unless defined? RosettaLogger