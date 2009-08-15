require 'rosetta_queue/consumer_managers/base'

module RosettaQueue
  class ThreadedManager < BaseManager

    def initialize
      @threads    = {}
      @running    = true
      @processing = true
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
    
    def shutdown_requested
      RosettaQueue.logger.error "Shutdown requested, starting to prune threads..."
      
      while @threads.any? { |n, t| t.alive? }
        RosettaQueue.logger.info "Calling stop_threads"
        stop_threads
        sleep 5
      end
    end

    def monitor_threads
      while @running
        trap("TERM") { shutdown_requested }
        trap("INT")  { shutdown_requested }
        living = false
        @threads.each { |name, thread| living ||= thread.alive? }
        @processing = @threads.any? { |name, thread| thread[:processing] }
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
      RosettaQueue.logger.debug("Attempting to stop all threads...")
      @running = false
      @threads.select { |key, thread| thread.alive? }.each do |key, thread|
        if thread[:processing]
          RosettaQueue.logger.debug("#{key} Skipping thread #{thread} because the consumer is processing")
          @running = true
          next
        end
        RosettaQueue.logger.debug("#{key} Stopping thread #{thread} and disconnecting the consumer")
        @consumers[key].disconnect
        thread.kill
      end
    end
  end
end
