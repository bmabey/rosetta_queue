require 'rosetta_queue/consumer_managers/base'
require 'mq'

module RosettaQueue
  
  class EventedManager < BaseManager
    
    def start
      EM.run {
        trap_interruptions

        begin
          @consumers.each do |key, consumer|
            RosettaQueue.logger.info("Running consumer #{key} in event machine...")
            consumer.receive
          end
        rescue Exception => e
          RosettaQueue.logger.error("Exception thrown: #{$!}\n" + e.backtrace.join("\n\t"))
        end
      }
    end
    
    def stop
      RosettaQueue.logger.info("Shutting down event machine...")
      EM.stop
    end

    private
    
      def trap_interruptions
        trap("INT") {
          RosettaQueue.logger.warn("Interrupt received.  Shutting down...")
          EM.stop
        }
        
        trap("TERM") {
          RosettaQueue.logger.warn("Interrupt received.  Shutting down...")
          EM.stop
        }
      end

  end
end
