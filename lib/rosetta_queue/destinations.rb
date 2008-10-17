module RosettaQueue

  class Destinations
    
    @dest = {}

    class << self
      attr_reader :dest

      def define
        yield self
      end
      
      def clear
        @dest.clear
      end
      
      def lookup(dest_name)
        mapping = dest[dest_name.to_sym]
        raise "No destination mapping for '#{dest_name}' has been defined!" unless mapping
        return mapping
      end
      
      def map(key, dest)
        @dest[key] = dest
      end
      
      def queue_names
        @dest.values
      end
    end

  end
end