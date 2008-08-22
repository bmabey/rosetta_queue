Dir[File.join(File.dirname(__FILE__), "adapters/*.rb")].each do |file|
  require file
end

module Messaging
  class Adapter

    class << self
      attr_accessor :user, :password, :host, :port, :type

      def define
        yield self
      end

      def instance
        raise AdapterException.new("Missing adapter type!") if @type.blank?
        generate_instance
      end

      private
      
        def generate_instance
          case @type
          when "stomp"
            Gateway::StompAdapter.open(@user, @password, @host, @port)
          else
            raise AdapterException.new("Adapter type does not match existing adapters!")
          end
        end
    end
  end  
end