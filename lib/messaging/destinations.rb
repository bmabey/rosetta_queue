module Messaging

  class Destinations
    
    @queue = {}

    class << self
      attr_reader :queue

      def define
        yield self
      end

      def lookup(queue_name)
        mapping = queue[queue_name.to_sym]
        raise "No queue destination mapping for '#{queue_name}' has been defined!" unless mapping
        return mapping
      end
      
      def map(key, destination)
        @queue[key] = destination
      end
    end

  end
end