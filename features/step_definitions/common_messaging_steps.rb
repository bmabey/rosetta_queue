Given /^consumer logs do not exist$/ do
  %w[p_to_p_log, pub_sub_log].each do |file_name|
    file_path = File.expand_path(File.dirname(__FILE__) + "/../support/#{file_name}.txt", "a")
    File.delete(file_path) if File.exists?(file_path)
  end 
end

Given /^RosettaQueue is configured for '(\w+)'$/ do |adapter_type|
  @adapter_type = adapter_type
  RosettaQueue::Adapter.define do |a|
    a.user      = "rosetta"
    a.password  = "password"
    a.host      = "localhost"
    a.type      = @adapter_type
    a.port      = case @adapter_type
                    when /stomp/
                    "61613"
                    when /beanstalk/
                    "11300"
                    else
                    nil
                    end
  end
end

Given /^a point-to-point destination is set with queue '(.*)' and queue address '(.*)'$/ do |key, queue|
  RosettaQueue::Destinations.define do |dest|
    dest.map key.to_sym, queue
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
  system("rabbitmqctl list_queues | grep #{queue}").should be_true
  RosettaQueue::Consumer.delete(queue.to_sym)
end

Then /^the queue '(.*)' should no longer exist$/ do |queue|
  system("rabbitmqctl list_queues | grep #{queue}").should be_false
end
