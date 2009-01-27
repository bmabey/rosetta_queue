require 'logger'

module RosettaQueue
  class MissingLogger < ::StandardError; end

  def self.logger=(new_logger)
    @logger = new_logger
  end
  
  def self.logger
    return @logger if @logger
    raise MissingLogger, "No logger has been set for RosettaQueue.  Please define one with RosettaQueue.logger=."
  end

end

module RosettaQueue

  class Logger < ::Logger

    def format_message(severity, timestamp, progname, msg)
      "\n[#{timestamp.to_formatted_s(:db)}] #{severity} #{msg}"
    end

  end

end
