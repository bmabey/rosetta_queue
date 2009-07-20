Given /^the message "(.+)" is published to queue "(.+)"$/ do |message, queue_name|
  publish_message(message, {:options => {:ack => "client"}}.merge(:to => queue_name))
end

When /^a message is published to queue '(\w+)'$/ do |q|
  publish_message("Hello World!", {:options => {:ack => "client"}}.merge(:to => q))
end

Then /^the message should be consumed$/ do
  RosettaQueue::Consumer.receive(:foo).should =~ /Hello World!/
  # consume_once_with(SampleConsumer).should =~ /Hello World!/
end
