module Messaging
  # Adds helpful methods when doing application level testing with rspec story runner.
  # Simply include this module in 'module Spec::Story::World' in your helper.rb.
  # If you are using cucumber you simply need to include it in your env.rb file.
  module StoryHelpers
    require 'open-uri'
    
    # *Currently* Assumes that ActiveMQ is being used as gateway and it will hit the web interface to clear
    # all the queues defined in the Messaging::Destinations mapping.
    def clear_queues
      Messaging::Destinations.queue_names.each do |name| 
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
      Messaging::Producer.publish(options[:to], message.to_json, options[:options])
    end
    
    # Consumes the first message defiend of the passed in consumer and uses the consumer to handle it.
    # Example:
    # consume_once_with ClientStatusConsumer
    def consume_once_with(consumer)
      consumer.new.on_message(Messaging::Consumer.receive(consumer.destination))
    end
    
  end
end