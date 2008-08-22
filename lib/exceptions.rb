class Exception
  include Notifiable, Loggable
end

class ActiveRecord::StandardError
  include Notifiable, Loggable
end

class MessagingError < StandardError; end
class DestinationNotFound < MessagingError; end
class MessagingVariableNotFound < MessagingError; end
class CallbackNotImplemented < MessagingError; end
class AdapterException < MessagingError; end
class StopProcessingException < Interrupt; end