Given /^multiple consumers are listening to queue '(.*)'$/ do |queue|
  @managers = []
  Thread.new do
    @managers << RosettaQueue::ThreadedManager.create do |m|
      m.add(eval_consumer_class(queue, "fooconsumer.log", "FooConsumer").new)
      m.start
    end
  end

  Thread.new do
    @managers << RosettaQueue::ThreadedManager.create do |m|
      m.add(eval_consumer_class(queue, "barconsumer.log", "BarConsumer").new)
      m.start
    end
  end
  sleep 5
end

Then /^multiple messages should be consumed from '(\w+)'$/ do |queue|
  ["FooConsumer", "BarConsumer"].each do |class_name, value|
     file_path = "#{CONSUMER_LOG_DIR}/#{class_name.downcase}.log"
     File.readlines(file_path).last.should =~ /Hello World! from #{class_name}/
  end
  @managers.each {|m| m.stop_threads }
end
