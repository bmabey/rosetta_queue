Then /^a (receiving|sending) filter is defined to prepend 'Foo' to all messages$/ do |filter_type|
  RosettaQueue::Filters.reset
  RosettaQueue::Filters.define do |f|
    f.send(filter_type) { |message| "Foo #{message}" }
  end
end

When /^the message on "(.+)" is consumed$/ do |queue_name|
  # TODO
  # @consumed_message = queue(:foo_queue).pop  
  @consumed_message = consume_once(queue_name.to_sym)
end

Then /^the consumed message should equal "(.+)"$/ do |consumed_message|
  @consumed_message.should == consumed_message
end

