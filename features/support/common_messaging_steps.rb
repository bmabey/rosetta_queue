Given /^RosettaQueue is configured for (\w+)$/ do |adapter_type|
  RosettaQueue::Adapter.define do |a|
    a.user      = "chris"
    a.password  = "fuzzbuzz!"
    a.host      = "localhost"
    a.type      = adapter_type
  end
end

Given /^a destination is set$/ do
  RosettaQueue::Destinations.define do |dest|
    dest.map :foo, "/queue/bar"
  end  
end