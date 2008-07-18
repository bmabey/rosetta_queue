module Messaging

  class Destinations
    
    @queue = {}

    class << self
      attr_reader :queue

      def define
        yield self
      end
      
      def map(key, destination)
        @queue[key] = destination
      end
    end

  end

end