Given /^RosettaQueue is configured for '(\w+)'$/ do |adapter_type|
  RosettaQueue::Adapter.define do |a|
    a.user      = "chris"
    a.password  = "fuzzbuzz!"
    a.host      = "localhost"
    a.type      = adapter_type
    a.port      = "61613" if adapter_type =~ /stomp/
  end
end

Given /^a point-to-point destination is set$/ do
  RosettaQueue::Destinations.define do |dest|
    dest.map :foo, "/queue/bar"
  end  
end

Given /^a publish-subscribe destination is set$/ do
  RosettaQueue::Destinations.define do |dest|
    dest.map :foobar, "/topic/foobar"
  end  
end
