module RosettaQueue
  module Matchers
    
    class PublishAMessageTo

      def initialize(expected_queue_name, options=nil)
        @options = options || {}
        @how_many_messages_expected = (@options[:exactly] || 1).to_i
        @expected_queue_name = expected_queue_name
        @expected_queue = expected_queue_name.is_a?(Symbol) ? RosettaQueue::Destinations.lookup(expected_queue_name) : expected_queue_name
      end

      def matches?(lambda_to_run)    
        #given
        RosettaQueue::Adapter.stub!(:instance).and_return(fake_adapter = RosettaQueue::Gateway::FakeAdapter.new)
        #when
        lambda_to_run.call
        #then
        @actual_queues = fake_adapter.queues      
        @number_of_messages_published = @actual_queues.select{ |q| q == @expected_queue}.size 
        @number_of_messages_published == @how_many_messages_expected
      end

      def failure_message
        "expected #{message_plural} published to the #{@expected_queue.inspect} queue but #{@number_of_messages_published} messages were"
      end

      def negative_failure_message
        "expected ##{message_plural} NOT to be published to the #{@expected_queue.inspect} queue but that queue was published to #{@number_of_messages_published} times"
      end

      def description
        "publish #{message_plural} to the '#{@expected_queue_name}' queue"
      end
      
    private
      def message_plural
        @how_many_messages_expected == 1 ? "a message" : "#{@how_many_messages_expected} messages"
      end
    end

    def publish_a_message_to(expected_queue)
      PublishAMessageTo.new(expected_queue)
    end
  
    alias :publish_message_to :publish_a_message_to
    
    def publish_messages_to(expected_queue, options)
      PublishAMessageTo.new(expected_queue, options)
    end
  
    class PublishMessageMatcher
    
    
      def matches?(lambda_to_run)
        #given
        RosettaQueue::Adapter.stub!(:instance).and_return(fake_adapter = RosettaQueue::Gateway::FakeAdapter.new)
        #when
        lambda_to_run.call
        #then
        message = fake_adapter.messages_sent_to(@expected_queue).first || ''
        @actual_message = message
      end
    
      protected
      def extract_options(options)
        if (expected_queue_name = options[:to])        
          @expected_queue = expected_queue_name.is_a?(Symbol) ? RosettaQueue::Destinations.lookup(expected_queue_name) : expected_queue_name
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
        Spec::Mocks::ArgumentConstraints::HashIncludingConstraint.new(@message_subset) == @actual_message
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

