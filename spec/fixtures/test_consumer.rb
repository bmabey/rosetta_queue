Messaging::Destinations.define do |queue|
  queue.map :test_queue, '/queue/test_queue'
end

class TestConsumer < Messaging::Consumer
  
  subscribes_to :test_queue
  options :persistent => false, :ack => "client"
  
  def on_message(msg)
    
  end
  
end