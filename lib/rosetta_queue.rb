Dir[File.join(File.dirname(__FILE__), "rosetta_queue/*.rb")].each do |file|
  require file
end

module RosettaQueue
  class MissingLogger < ::StandardError; end

  def self.logger=(new_logger)
    @logger = new_logger
  end
  
  def self.logger
    return @logger if @logger
    raise MissingLogger, "No logger has been set for RosettaQueue.  Please define one with RosettaQueue.logger=."
  end

  def self.load_spec_helpers
    Dir[File.join(File.dirname(__FILE__), 'rosetta_queue', 'spec_helpers/*.rb')].each do |file|
      require file
    end
  end

end
                               
