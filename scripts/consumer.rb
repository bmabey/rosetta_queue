require File.dirname(__FILE__) + '/../config/loader.rb'

puts "Starting up message consumers...\n"
puts "PRESS CONTROL-C TO SHUT DOWN GRACEFULLY\n\n"

# instantiate gateway objects which observe specific queues or topics and push received messages
# on to a strategy object


class Autoresponder
  include MessageHandler
  subscribes_to :sale
  options :persistent => false, :ack => "client"

  def on_message(message)
     puts "sending email for message '#{message}'"
  end
end

class Billing
  include MessageHandler
  subscribes_to :sale
  options :persistent => false, :ack => "client"

  def on_message(message)
     puts "billing for message '#{message}'"
  end
end

class Shipping
  include MessageHandler
  subscribes_to :sale
  options :persistent => false, :ack => "client"

  def on_message(message)
     puts "shipping for message '#{message}'"
  end
end


# instantiate subscription manager to handle threading and monitoring of added gateway observers
Messaging::ConsumerManager.create do |m|

  m.add(Autoresponder.new)
  m.add(Billing.new)
  m.add(Shipping.new)

  #start subscriptions
  m.start
end