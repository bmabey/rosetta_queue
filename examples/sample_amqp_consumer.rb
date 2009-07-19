require 'rubygems'
require File.dirname(__FILE__) + '/../init.rb'
require File.expand_path(File.dirname(__FILE__) + '/../lib/rosetta_queue/consumer_managers/threaded')

module RosettaQueue

  Adapter.define do |a|
    a.user      = "rosetta"
    a.password  = "password"
    a.host      = "localhost"
    a.type      = 'amqp_synch'
  end

  Destinations.define do |dest|
    dest.map :foo, "queuep.foo"
  end  

  class MessageHandlerFoo
    include RosettaQueue::MessageHandler
    subscribes_to :foo
    options :ack => true
    attr_reader :msg

    def on_message(msg)
      puts "FOO received message: #{msg}"
    end

  end

  ThreadedManager.create do |m|
    m.add MessageHandlerFoo.new
    m.start
  end 

end
