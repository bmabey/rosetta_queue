Messaging::Destinations.define do |queue| 
  queue.map :test_queue, '/queue/test_queue'
end

class TestConsumer
  include MessageHandler

  subscribes_to :test_queue
  options :persistent => false, :ack => "client"

  def on_message(msg)

  end
end


class TestConsumerWithoutOnMessage
  include MessageHandler

  subscribes_to :test_queue
  options :persistent => false, :ack => "client"

end


# class TestSingularConsumer < Messaging::Consumer
# 
#   subscribes_to :test_queue
#   will_consume :once
#   options :persistent => false, :ack => "client"
# 
#   def on_message(msg)
# 
#   end
# end