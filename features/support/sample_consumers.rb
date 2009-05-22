require File.expand_path(File.dirname(__FILE__) + '/env.rb')

class SampleConsumer
  include ::RosettaQueue::MessageHandler
  subscribes_to :foo
  options :durable => true
  
  attr_reader :msg
  
  def on_message(msg)
    @msg = msg
    puts "MESSAGE #{msg}"
  end
  
end


class SampleConsumerTwo
  include ::RosettaQueue::MessageHandler
  subscribes_to :foo
  options :durable => true
  
  attr_reader :msg
  
  def on_message(msg)
    @msg = msg
  end
  
end
