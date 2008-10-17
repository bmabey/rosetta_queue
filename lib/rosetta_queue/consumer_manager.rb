module RosettaQueue
  class ConsumerManager

    attr_reader :consumers

    class << self
      def create
        yield self.new
      end
    end

    def initialize
      @consumers  = {}
      @threads    = {}
      @running    = true
    end

    def add(message_handler)
      key = message_handler.class.to_s.underscore.to_sym
      @consumers[key] = Consumer.new(message_handler)
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

    def start_threads
      @consumers.each do |key, consumer|
        @threads[key] = Thread.new(key, consumer) do |a_key, a_consumer|
          while @running
            begin
              a_consumer.receive
            rescue StopProcessingException=>e
              e.log_error
              e.send_notification
              puts "#{a_key}: Processing Stopped - receive interrupted"
            rescue Exception=>e
              e.log_error
              e.send_notification
              puts "#{a_key}: Exception from connection.receive: #{$!}\n" + exception.backtrace.join("\n\t")
            end
            Thread.pass
          end
        end
      end      
    end

    def stop_threads
      @running = false
      @threads.each do |key, thread|
        puts "Stopping thread and unsubscribing from #{key}" unless ENV["MESSAGING_ENV"] == "test"
        @consumers[key].unsubscribe
        puts "Stopping thread and disconnecting from #{key}" unless ENV["MESSAGING_ENV"] == "test"
        @consumers[key].disconnect
        thread.kill
      end
    end
  end
end