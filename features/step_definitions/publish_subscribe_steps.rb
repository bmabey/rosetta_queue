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
