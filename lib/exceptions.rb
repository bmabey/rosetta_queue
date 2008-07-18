class Exception
  include Notifiable, Loggable
end

class ActiveRecord::StandardError
  include Notifiable, Loggable
end

class DimensionError < StandardError; end
class DimensionNotFound < DimensionError; end
class IdNotFound < DimensionError; end
class MessageVariableNotFound < StandardError; end
class ModelFailedToSave < StandardError; end
class GatewayError < StandardError; end
class ObserverError < GatewayError; end
class StopProcessingException < Interrupt; end