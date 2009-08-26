def eval_consumer_class(queue, log_file="point-to-point.log", klass_name=nil)
  klass_name = "#{queue.to_s.capitalize}Consumer" if klass_name.nil?
  return if Object.const_defined?(klass_name)
  options = {}
  unless @adapter_type == "stomp"
    options = ":ack => true"
  else 
    options = ":ack => 'client'"
  end 

  str = <<-EOC
    class #{klass_name}
      include RosettaQueue::MessageHandler
      subscribes_to :#{queue}
      options #{options}
    
      def on_message(msg)
        begin
          file_path = "#{CONSUMER_LOG_DIR}/#{log_file}"
          File.open(file_path, "w+") do |f|
            f << msg + " from #{klass_name}"
          end 
        rescue Exception => e
          puts e.message
        end 
      end
    end
  EOC

  eval(str)
  Object.const_get(klass_name)
end 

Given /^consumer logs have been cleared$/ do
    %w[point-to-point pub-sub fooconsumer barconsumer].each do |file_name|
      file_path = "#{CONSUMER_LOG_DIR}/#{file_name}.log"
      File.delete(file_path) if File.exists?(file_path)
      File.open(file_path, "a+")
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

Given /^a destination is set with queue '(.*)' and queue address '(.*)'$/ do |key, queue|
  RosettaQueue::Destinations.define do |dest|
    dest.map key.to_sym, queue
  end  
end

Given /^the message '(.+)' is published to queue '(.+)'$/ do |message, queue_name|
  publish_message(message, {:to => queue_name})
end

When /^a message is published to '(\w+)'$/ do |q|
  RosettaQueue::Producer.publish(q.to_sym, "Hello World!")
#  publish_message("Hello World!", {:options => {:to => q}})
end

When /^the queue '(.*)' is deleted$/ do |queue|
  system("rabbitmqctl list_queues | grep #{queue}").should be_true
  RosettaQueue::Consumer.delete(queue.to_sym)
end

Then /^the queue '(.*)' should no longer exist$/ do |queue|
  system("rabbitmqctl list_queues | grep #{queue}").should be_false
end
