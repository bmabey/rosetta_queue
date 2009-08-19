When /^a message is published to '(\w+)'$/ do |topic|
  RosettaQueue::Producer.publish(topic.to_sym, "Hello World!", {:durable => true})
  # publish_message("Hello World!", {:options => {:ack => "client"}}.merge(:to => topic))
end

Then /^multiple messages should be consumed from the topic$/ do
  sleep 1
  RosettaQueue::Consumer.receive(:foobar).should =~ /Hello World!/
  # RosettaQueue::Consumer.receive(:bar).should =~ /Hello World!/
  # consume_once_with(SampleConsumer).should == "Hello World!"
end

Given /^multiple consumers are listening to queue '(.*)'$/ do |queue|
  klass = eval_consumer_class(queue)
  @thread = Thread.new do
    cons = klass.new
    case @adapter_type
    when /evented/
      EM.run do
        RosettaQueue::Consumer.new(cons).receive
      end 
    else
      RosettaQueue::Consumer.new(cons).receive
    end 
  end 
end

Then /^the message should be consumed from '(\w+)'$/ do |queue|
  file_path = "#{CONSUMER_LOG_DIR}/p_to_p_log.txt"
  sleep 1 unless File.exists?(file_path)
  File.readlines(file_path).last.should =~ /Hello World! from #{queue}/
  @thread.kill
end
