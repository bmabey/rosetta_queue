When /^a message is published to topic (\w+)$/ do |topic|
  publish_message("Hello World!", {:options => {:ack => "client"}}.merge(:to => topic))
end

Then /^multiple messages should be consumed from the topic$/ do
  sleep 1
  consume_once_with(SampleConsumer).should == "Hello World!"
end