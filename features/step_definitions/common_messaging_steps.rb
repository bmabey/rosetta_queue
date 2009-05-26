Given /^RosettaQueue is configured for '(\w+)'$/ do |adapter_type|
  RosettaQueue::Adapter.define do |a|
    a.user      = "rosetta"
    a.password  = "password"
    a.host      = "localhost"
    a.type      = adapter_type
    a.port      = case adapter_type
                    when /stomp/
                    "61613"
                    when /beanstalk/
                    "11300"
                    else
                    nil
                    end
  end
end

Given /^a point-to-point destination is set$/ do
  RosettaQueue::Destinations.define do |dest|
    dest.map :foo, "/queue/bar"
  end  
end

Given /^a '(.*)' destination is set$/ do |pub_sub|
  case pub_sub
  when /fanout/
    RosettaQueue::Destinations.define do |dest|
      dest.map :foobar, "/fanout/foobar"
    end  
  when /topic/
    RosettaQueue::Destinations.define do |dest|
      dest.map :foobar, "/topic/foobar"
    end  
  end 
end

When /^the queue '(.*)' is deleted$/ do |queue|
  RosettaQueue::Consumer.delete(queue.to_sym)
end

Then /^the queue 'foo' should no longer exist$/ do
  pending
#  system()
end
