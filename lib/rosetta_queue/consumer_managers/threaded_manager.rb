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
        RosettaQueue.logger.warn("Interrupt received.  Shutting down...")
        puts "\nInterrupt received\n"
      rescue Exception=>e
        RosettaQueue.logger.error("Exception thrown -- #{e.class.name}: #{e.message}")
      ensure
        RosettaQueue.logger.warn("Cleaning up threads...")
        stop_threads
    end

    def start_threads
      @consumers.each do |key, consumer|
        @threads[key] = Thread.new(key, consumer) do |a_key, a_consumer|
          while @running
            begin
              RosettaQueue.logger.info("Threading consumer #{a_consumer}...")
              Mutex.new.synchronize { a_consumer.receive }
            rescue StopProcessingException=>e
              RosettaQueue.logger.error("#{a_key}: Processing Stopped - receive interrupted")
            rescue Exception=>e
              RosettaQueue.logger.error("#{a_key}: Exception from connection.receive: #{$!}\n" + e.backtrace.join("\n\t"))
            end
            Thread.pass
          end
        end
      end      
    end

    def stop_threads
      @running = false
      @threads.each do |key, thread|
        RosettaQueue.logger.info("Stopping thread and disconnecting from #{key}...")
        @consumers[key].disconnect
        thread.kill
      end
    end
  end
end