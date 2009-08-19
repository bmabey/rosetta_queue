require 'time'

class Time

  DATE_FORMATS = {
    :db           => "%Y-%m-%d %H:%M:%S",
    :number       => "%Y%m%d%H%M%S",
    :time         => "%H:%M",
    :short        => "%d %b %H:%M",
    :long         => "%B %d, %Y %H:%M",
    :long_ordinal => lambda { |time| time.strftime("%B #{time.day.ordinalize}, %Y %H:%M") },
    :rfc822       => lambda { |time| time.strftime("%a, %d %b %Y %H:%M:%S #{time.formatted_offset(false)}") }
  }

  def to_formatted_s(format = :default)
    return to_default_s unless formatter = DATE_FORMATS[format]
    formatter.respond_to?(:call) ? formatter.call(self).to_s : strftime(formatter)
  end

end 
