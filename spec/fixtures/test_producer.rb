Messaging::Adapter.type = :stomp

Messaging::Destinations.define do |queue|
  queue.map :test_queue, '/queue/test_queue'
end

class TestProducer < Messaging::Producer
  
  publishes_to :test_queue
  options :persistent => false

end