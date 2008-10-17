module RosettaQueue
  
  class Base

    def disconnect
      connection.disconnect
    end

    def unsubscribe
      connection.unsubscribe(destination)
    end

    protected
     def connection
       @conn ||= Adapter.instance
     end

  end
end