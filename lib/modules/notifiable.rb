module Notifiable
  TO    = "cwyckoff@alliancehealth.com"
  FROM  = "errors@alliancehealth.com"

  def send_notification(msg = "Here's the backtrace:\n'#{self.backtrace.join("\n")}")
    if(ENV["ETL_ENV"] == "test")
      log_notification(msg)
    else
      send_email_notification(msg)
    end
  end

private
  def log_notification(msg)
    File.open("#{ROOT}/tmp/test_error_log.txt", "a") do |f|
      f << msg
    end
  end

  def merge_headers_with(msg)
    message = "From: #{FROM}\nTo:#{TO}\nSubject: Something happened in the Data Mart ETL.\n\n"
    message << "From #{self.class.name} with the message #{$!}\n\n"
    message << msg
  end

  def send_email_notification(msg)
    msg = merge_headers_with(msg)

    Net::SMTP.start('localhost') do |smtp|
      smtp.send_message msg, FROM, TO
    end    
  end
end