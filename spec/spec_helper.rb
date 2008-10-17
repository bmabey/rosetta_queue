ENV["MESSAGING_ENV"] = "test"

require 'rubygems'
require 'spec'

require File.dirname(__FILE__) + '/../init.rb'
require File.dirname(__FILE__) + '/rosetta_queue/shared_messaging_behavior.rb'

Dir[File.join(File.dirname(__FILE__), '..', 'lib', 'rosetta_queue', 'spec_helpers/*.rb')].each do |file|
  require file
end

alias :running :lambda

[:process].each do |action|
  eval %Q{
    def before_#{action}
      yield
      do_#{action}
    end
    alias during_#{action} before_#{action}
    def after_#{action}
      do_#{action}
      yield
    end
  }
end