module RosettaQueue
  # Adds helpful methods when doing application level testing.
  # If you are using cucumber just include it in your Wolrd in the env.rb file:
  # World {|world| world.extend RosettaQueue::SpecHelpers }
  module SpecHelpers
    require 'open-uri'
    
    # *Currently* only works with ActiveMQ being used as gateway. 
    # This will clear the queues defined in the RosettaQueue::Destinations mapping.
    # TODO: Figure out a better spot for this to allow for other gateways...
    def clear_queues
      RosettaQueue::Destinations.queue_names.each do |name| 
        queue = name.gsub('/queue/','')
        open("http://127.0.0.1:8161/admin/deleteDestination.action?JMSDestination=#{queue}&JMSDestinationType=queue")
      end
    end
    
    # Publishes a given hash as json to the specified destination. 
    # Example:
    # publish_message(expected_message, :to => :client_status, :options => {...})
    # The :options will be passed to the publisher and are optional.
    def publish_message(message, options)
      options[:options] ||= {:persistent => false}
      RosettaQueue::Producer.publish(options[:to], message, options[:options])
    end
    
    # Consumes the first message on queue of consumer that is passed in and uses the consumer to handle it.
    # Example:
    # consume_once_with ClientStatusConsumer
    def consume_once_with(consumer)
      consumer.new.on_message(RosettaQueue::Consumer.receive(consumer.destination))
    end
    
    # Consumes the first message on queue and returns it.
    # Example:
    # message = consume_once :foo_queue
    def consume_once(dest)
      RosettaQueue::Consumer.receive(dest)
    end

    def consuming_from(destination)
      sleep 1
      Messaging::Consumer.receive(destination, :persistent => false).to_hash_from_json
    end
    
  end
end
