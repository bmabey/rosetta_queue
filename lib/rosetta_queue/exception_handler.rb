# == ExceptionHandler
#
# RQ allows you to register exception handlers for different parts of messaging.
# The handlers can be a class with a ::handle method or simply a block.
# In both cases the handler needs to accept as arguments the exception and
# an additional info hash which contains useful information about the context
# in which the error was raised (i.e. the message involved).
#
# An example of class exception handler:
#
#   class MessagingExceptionHandler
#     def self.handle(exception, info)
#       RosettaQueue.logger.error("An exception occurred when #{info[:action]} to/from #{info[:destination]}: \n#{e.message}\n#{e.backtrace.join("\n")}")
#       RosettaQueue.logger.error("Message that caused exception:\n #{info[:message]}")
#     end
#   end
#
# You can register it like so:
#
#   RosettaQueue::ExceptionHandler.register(:all, MessagingExceptionHandler)
#
#
# Instead of :all you can specify the :consuming or :publishing action.
#
# Or you can register a block like so:
#
#   RosettaQueue::ExceptionHandler.register(:all) do |exception, info|
#     # ....
#   end
#
# == Define DSL
#
# Like the other parts of RQ you can configure it with ::define (instead of using the
# ::register call).  Here is an example of that using the block handler:
#
#  RosettaQueue::ExceptionHandler.define do |handler|
#    handler.for(:all) do |exception, info|
#      case exception
#      when SomeSpecificError
#        #.....
#      else
#        #...
#        #...
#      end
#    end
#
#    handler.for(:consuming) do |exception, info|
#      # this will be called just for consuming errors in 
#      # addition to the :all one above
#    end
#  end
#


module RosettaQueue
  class ExceptionHandler
    class << self

      def handle(messaging_action=:all, info_or_proc={})
        yield
      rescue Exception => e
        handlers = handlers_for(messaging_action)
        raise e if handlers.empty?
        info = info_or_proc.respond_to?(:call) ? info_or_proc.call : info_or_proc
        handlers.each { |h| h.handle(e, info) }
      end


      def define
        yield self
      end

      def reset_handlers
        @handlers = Hash.new { |h, k| h[k] = [] }
      end

      def register(messaging_action, handler_klass=nil, &block)
        handler = handler_klass
        if block_given?
          def block.handle(*args)
            call(*args)
          end
          handler = block
        end

        handlers[messaging_action] << handler
      end

      alias for register

      private

      def handlers
        @handlers || reset_handlers
      end

      def handlers_for(messaging_action)
        return handlers[:all] if messaging_action == :all

        handlers[messaging_action] + handlers[:all]
      end

    end
  end
end
