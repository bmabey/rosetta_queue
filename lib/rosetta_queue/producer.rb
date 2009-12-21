module RosettaQueue

  class Producer
    include MessageHandler

    def self.publish(destination, message, options = {})
      ExceptionHandler::handle(:publishing,
        lambda {
          {:message => Filters.safe_process_sending(message),
           :action => :publishing,
           :destination => destination,
           :options => options}
        }) do
        RosettaQueue::Adapter.open do |a|
          a.send_message(
            Destinations.lookup(destination),
            Filters.process_sending(message),
            options)
        end
      end
    end
  end
end
