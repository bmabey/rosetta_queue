When /^a message is published to queue (\w+)$/ do |q|
  publish_message("Hello World!", {:options => {:durable => false}}.merge(:to => q))
  EM.stop
end

Then /^the message should be consumed$/ do
  RosettaQueue::EventedManager.create do |m|
    m.add(cons = UpdateOffer.new)
    m.start      
    sleep 1
    cons.msg.should == "Hello World!"
    m.stop
  end
end