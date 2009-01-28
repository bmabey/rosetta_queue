module RosettaQueue

  class RosettaQueueError < StandardError; end
  class DestinationNotFound < RosettaQueueError; end
  class RosettaQueueVariableNotFound < RosettaQueueError; end
  class CallbackNotImplemented < RosettaQueueError; end
  class AdapterException < RosettaQueueError; end
  class StopProcessingException < Interrupt; end

end
