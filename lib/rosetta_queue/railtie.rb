class RosettaQueueRailtie < Rails::Railtie
  initialization "rosetta_queue" do
    RosettaQueue.logger = RosettaQueue::Logger.new(File.join(Rails.root, 'log', 'rosetta_queue.log'))
    require('rosetta_queue/spec_helpers') if Rails.env == "test"
  end
end
