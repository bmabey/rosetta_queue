Given /^a consumer is listening to queue '(.*)'$/ do |queue|
  klass = eval_consumer_class(queue)
  @thread = Thread.new do
    cons = klass.new
    case @adapter_type
    when /evented/
      EM.run do
        RosettaQueue::Consumer.new(cons).receive
      end 
    else
      RosettaQueue::Consumer.new(cons).receive
    end 
  end 
end

Then /^the message should be consumed from '(.*)'$/ do |queue|
  file_path = "#{CONSUMER_LOG_DIR}/p_to_p_log.txt"
  sleep 1 unless File.exists?(file_path)
  File.readlines(file_path).last.should =~ /Hello World! from #{queue}/
  @thread.kill
end
