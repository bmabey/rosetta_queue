Given /^the message '(.+)' is published to queue '(.+)'$/ do |message, queue_name|
  publish_message(message, {:to => queue_name})
end

Given /^a consumer is listening to queue '(.*)'$/ do |queue|
  str = <<-EOC
    class SampleCons
      include ::RosettaQueue::MessageHandler
      subscribes_to :#{queue}
      options :ack => true
    
      def on_message(msg)
        file_path = File.expand_path(File.dirname(__FILE__) + "/features/support/tmp/p_to_p_log.txt")
        File.open(file_path, "w") do |f|
          f << msg
        end 
      end
    end
  EOC

    eval(str)
    
    @thread = Thread.new do
      cons = SampleCons.new
      RosettaQueue::Consumer.new(cons).receive
    end 
end

When /^a message is published to queue '(\w+)'$/ do |q|
  publish_message("Hello World!", {:options => {:ack => "client"}}.merge(:to => q))
end

Then /^the message should be consumed$/ do
    file_path = File.expand_path(File.dirname(__FILE__) + "/../support/tmp/p_to_p_log.txt")
    File.readlines(file_path).last.should =~ /Hello World!/
    
  #  RosettaQueue::Consumer.receive(:foo).should =~ /Hello World!/
  # consume_once_with(SampleConsumer).should =~ /Hello World!/
    @thread.kill
end
