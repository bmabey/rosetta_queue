#
# manages subscriptions to destinations (i.e., queues and topics).  subscriptions are
# encapsulated in a gateway object so the SubscriptionManager is a container for 
# gateway objects.  once loaded, the subscriptions can be started by calling
# the "start" command, which adds each subscription to a thread where the gateway
# "receive" method is called.  those threads are then monitored for interruptions, 
# stopped processes, or other errors.  once a thread dies, all threads are stopped.
#
module Messaging
  class SubscriptionManager

    attr_reader :subscriptions

    class << self
      def create
        yield self.new
      end
    end

    def initialize
      @subscriptions  = {}
      @threads        = {}
      @running        = true
    end

    def add(key, subscription)
      @subscriptions[key] = subscription
    end

    def start
      start_threads
      join_threads
      monitor_threads
    end

    def stop
      stop_threads
    end

  private

    def join_threads
      @threads.each { |thread| thread.join }
    end

    # checks to make sure each thread is alive.  if not, stops all threads
    def monitor_threads
      while @running
        trap("TERM", "EXIT")
        living = false
        @threads.each { |name, thread| living ||= thread.alive? }
        @running = living
        sleep 1
      end

      puts "All connection threads have died..."
      rescue Interrupt=>e
        e.log_error
        puts "\nInterrupt received\n"
      rescue Object=>e
        e.log_error
        e.send_notification
        puts "\n#{e.class.name}: #{e.message}\n\n"
      ensure
        puts "Cleaning up threads...\n\n"
        stop_threads
    end

    # starts a thread for each conection
    def start_threads
      @subscriptions.each do |name, gateway|
        @threads[name] = Thread.new(name, gateway) do |a_name, a_gateway|
          while @running
            begin
              a_gateway.receive
            rescue StopProcessingException=>e
              e.log_error
              e.send_notification
              puts "#{a_name}: Processing Stopped - receive interrupted"
            rescue Exception=>e
              e.log_error
              e.send_notification
              puts "#{a_name}: Exception from connection.receive: #{$!}\n" + exception.backtrace.join("\n\t")
            end
            Thread.pass
          end
        end
      end      
    end

    # unsubscribes and disconnects each gateway subscription, and then kills each thread
    def stop_threads
      @running = false

      @threads.each do |name, thread|
        puts "Stopping thread and unsubscribing from #{name}" unless ENV["MESSAGING_ENV"] == "test"
        @subscriptions[name].unsubscribe
        puts "Stopping thread and disconnecting from #{name}" unless ENV["MESSAGING_ENV"] == "test"
        @subscriptions[name].disconnect
        thread.kill
      end
    end
  end
end