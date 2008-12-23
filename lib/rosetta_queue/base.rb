module RosettaQueue
  
  class Base

    def disconnect
      connection.disconnect(@message_handler)
    end

    protected
     def connection
       @conn ||= Adapter.instance
     end

  end
end