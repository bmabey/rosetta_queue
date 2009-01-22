module RosettaQueue

  class Logger < ::Logger

    def format_message(severity, timestamp, progname, msg)
      "\n[#{timestamp.to_formatted_s(:db)}] #{severity} #{msg}"
    end

  end

end
