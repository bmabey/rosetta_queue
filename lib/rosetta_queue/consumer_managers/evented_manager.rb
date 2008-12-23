require 'mq'

module RosettaQueue
  
  class EventedManager < BaseManager
    
    def start
      EM.run {
        trap_interruptions

        begin
          @consumers.each do |key, consumer|
            RosettaLogger.info("Running consumer #{key} in event machine...")
            consumer.receive
          end
        rescue Exception => e
          RosettaLogger.error("Exception thrown: #{$!}\n" + e.backtrace.join("\n\t"))
        end
      }
    end
    
    def stop
      RosettaLogger.info("Shutting down event machine...")
      EM.stop
    end

    private
    
      def trap_interruptions
        trap("INT") {
          RosettaLogger.warn("Interrupt received.  Shutting down...")
          EM.stop
        }
        
        trap("TERM") {
          RosettaLogger.warn("Interrupt received.  Shutting down...")
          EM.stop
        }
      end

  end
end