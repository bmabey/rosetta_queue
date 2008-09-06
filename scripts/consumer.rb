require File.dirname(__FILE__) + '/../config/loader.rb'

puts "Starting up message consumers...\n"
puts "PRESS CONTROL-C TO SHUT DOWN GRACEFULLY\n\n"

# instantiate gateway objects which observe specific queues or topics and push received messages
# on to a strategy object


class Autoresponder
  include Consumeable

  subscribes_to :autoresponder
  options :persistent => false, :ack => "client"

  def on_message(message)
     puts "sending email for message '#{message.body}'"
  end

end

ar_consumer = Messaging::Consumer.new
ar_consumer.add(Autoresponder.new)
  
# instantiate subscription manager to handle threading and monitoring of added gateway observers
Messaging::SubscriptionManager.create do |m|

  m.add :autoresponder, ar_consumer

  #start subscriptions
  m.start
end