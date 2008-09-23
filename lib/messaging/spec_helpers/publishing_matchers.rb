module Messaging
  module Matchers
    
    class PublishAMessageTo

      def initialize(expected_queue_name)
        @expected_queue_name = expected_queue_name
        @expected_queue = expected_queue_name.is_a?(Symbol) ? Messaging::Destinations.lookup(expected_queue_name) : expected_queue_name
      end

      def matches?(lambda_to_run)    
        #given
        Messaging::Adapter.stub!(:instance).and_return(fake_adapter = Messaging::Gateway::FakeAdapter.new)
        #when
        lambda_to_run.call
        #then
        @actual_queues = fake_adapter.queues      
        @actual_queues.include?(@expected_queue)
      end

      def failure_message
        "expected a message published to the #{@expected_queue.inspect} queue but messages were delivered to #{@actual_queues.inspect}"
      end

      def negative_failure_message
        "expected a message NOT to be published to the #{@expected_queue.inspect} queue but was"
      end

      def description
        "publish a message to the '#{@expected_queue_name}' queue"
      end
    end

    def publish_a_message_to(expected_queue)
      PublishAMessageTo.new(expected_queue)
    end
  
    alias :publish_message_to :publish_a_message_to
  
    class PublishMessageMatcher
    
    
      def matches?(lambda_to_run)
        #given
        Messaging::Adapter.stub!(:instance).and_return(fake_adapter = Messaging::Gateway::FakeAdapter.new)
        #when
        lambda_to_run.call
        #then
        message = fake_adapter.messages_sent_to(@expected_queue).first || ''
        @actual_message = message.to_hash_from_json
      end
    
      protected
      def extract_options(options)
        if (expected_queue_name = options[:to])        
          @expected_queue = expected_queue_name.is_a?(Symbol) ? Messaging::Destinations.lookup(expected_queue_name) : expected_queue_name
        end
      end
    end
  
    class PublishMessageWith < PublishMessageMatcher
        
      def initialize(message_subset, options)
        @message_subset = message_subset
        extract_options(options)
      end

      def matches?(lambda_to_run)    
        super
        Spec::Mocks::HashIncludingConstraint.new(@message_subset).matches?(@actual_message) == true
      end

      def failure_message
        if @actual_message.blank?
          "expected #{@message_subset.inspect} to be contained in a message but no message was published"        
        else
          "expected #{@message_subset.inspect} to be contained in the message: #{@actual_message.inspect}"
        end
      end

      def negative_failure_message
        "expected #{@message_subset.inspect} not to be contained in the message but was"
      end

      def description
        "publish a message with #{@message_subset.inspect}"
      end
        
    end
    
    def publish_message_with(message_subset, options={})
      PublishMessageWith.new(message_subset, options)
    end
  
  
    class PublishMessage < PublishMessageMatcher
        
      def initialize(expected_message, options)
        @expected_message = expected_message
        extract_options(options)
      end

      def matches?(lambda_to_run)    
        super
        @actual_message == @expected_message
      end

      def failure_message
        if @actual_message.blank?
          "expected #{@expected_message.inspect} to be published but no message was"        
        else
          "expected #{@expected_message.inspect} to be published but the following was instead: #{@actual_message.inspect}"
        end
      end

      def negative_failure_message
        "expected #{@expected_message.inspect} not to be published but it was"
      end

      def description
        "publish the message: #{@expected_message.inspect}"
      end
        
    end
    
    def publish_message(exact_expected_message, options={})
      PublishMessage.new(exact_expected_message, options)
    end
    
  end
end

