ENV["MESSAGING_ENV"] = "test"

require 'rubygems'
require 'spec'
require 'ruby-debug'
require File.dirname(__FILE__) + '/../config/loader.rb'
require File.dirname(__FILE__) + '/fixtures/test_producer.rb'
require File.dirname(__FILE__) + '/fixtures/test_consumer.rb'
require File.dirname(__FILE__) + '/messaging/shared_messaging_behavior.rb'

alias :running :lambda

[:get, :post, :action, :process].each do |action|
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