require 'mq'

module RosettaQueue
  
  class EventedManager < BaseManager
    
    def start
      EM.run {
        trap_interruptions

        @consumers.each do |key, consumer|
          consumer.receive
        end
      }
    end
    
    def stop
      EM.stop
    end

    private
    
      def trap_interruptions
        trap("INT") { EM.stop }
        trap("TERM") { EM.stop }
      end

  end
end