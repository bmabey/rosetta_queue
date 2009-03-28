require 'rubygems'
require File.dirname(__FILE__) + '/../init.rb'
require File.expand_path(File.dirname(__FILE__) + '/../lib/rosetta_queue/consumer_managers/evented.rb')

module RosettaQueue

  RosettaQueue.logger = Logger.new(File.expand_path(File.dirname(__FILE__) + '/../../rosetta_queue_example_log/rosetta_queue.log'))

  class SampleConsumerFoo
    include RosettaQueue::MessageHandler
    subscribes_to :foo
    options :client => "ack"
    
    attr_reader :msg

    def on_message(msg)
      puts "MESSAGE RECEIVED: #{msg}"
    end
  end

  Adapter.define do |a|
    a.user      = "rosetta"
    a.password  = "password"
    a.host      = "localhost"
    a.type      = 'amqp'
  end

  Destinations.define do |dest|
    dest.map :foo, "/queue/foo"
  end  

  EventedManager.create do |m|
    m.add SampleConsumerFoo.new
    m.start
  end 

end
