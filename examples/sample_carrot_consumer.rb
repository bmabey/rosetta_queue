require 'rubygems'
require File.dirname(__FILE__) + '/../init.rb'
require File.expand_path(File.dirname(__FILE__) + '/../lib/rosetta_queue/consumer_managers/threaded.rb')

module RosettaQueue

  RosettaQueue.logger = Logger.new(File.expand_path(File.dirname(__FILE__) + '/../../log/rosetta_queue.log'))

  class SampleConsumerFoo
    include RosettaQueue::MessageHandler
    subscribes_to :foo
    options :ack => true
    
    attr_reader :msg

    def on_message(msg)
      puts "MESSAGE RECEIVED: #{msg}"
    end
  end

  Adapter.define do |a|
    a.user      = "rosetta"
    a.password  = "password"
    a.host      = "localhost"
    a.type      = 'amqp_carrot'
  end

  Destinations.define do |dest|
    dest.map :foo, "/fanout/foo"
  end  

  ThreadedManager.create do |m|
    m.add SampleConsumerFoo.new
    m.start
  end 

end
