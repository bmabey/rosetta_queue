module RosettaQueue
  class ThreadedManager < BaseManager

    def initialize
      @threads    = {}
      @running    = true
      super
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
        puts "\nInterrupt received\n"
      rescue Object=>e
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
              Mutex.new.synchronize { a_consumer.receive }
            rescue StopProcessingException=>e
              puts "#{a_key}: Processing Stopped - receive interrupted"
            rescue Exception=>e
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
        puts "Stopping thread and disconnecting from #{key}" unless ENV["MESSAGING_ENV"] == "test"
        @consumers[key].disconnect
        thread.kill
      end
    end
  end
end