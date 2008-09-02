module Loggable

  def logger
    @@logger ||= Logger.new(LOG_ROOT + '/errors.log', 'monthly')
  end

  def log_error
    logger.error("#{Time.now.to_s}:: #{self.class.name}:: #{$!}\n#{self.backtrace.join("\n\t")}")
  end

end