class SampleConsumer
  include MessageHandler
  subscribes_to :foo
  options :durable => true
  
  attr_reader :msg
  
  def on_message(msg)
    @msg = msg
    puts "MESSAGE #{msg}"
  end
  
end


# class SampleConsumerTwo
#   include MessageHandler
#   subscribes_to :foo
#   options :durable => true
#   
#   attr_reader :msg
#   
#   def on_message(msg)
#     @msg = msg
#   end
#   
# end
