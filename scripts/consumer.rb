require File.dirname(__FILE__) + '/../config/loader.rb'

puts "Starting up message consumers...\n"
puts "PRESS CONTROL-C TO SHUT DOWN GRACEFULLY\n\n"

# instantiate gateway objects which observe specific queues or topics and push received messages
# on to a strategy object


class Autoresponder < Messaging::Consumer

  subscribes_to :autoresponder
  options :persistent => false, :ack => "client"

  FROM = 'sales@widgetsRUs.com'

  def on_message(message)
     puts "sending email for message '#{message.body}'"

     # Net::SMTP.start('localhost') do |smtp|
     #   smtp.send_message("Thanks for your order!", FROM, msg["email"])
     # end
  end

end

# instantiate subscription manager to handle threading and monitoring of added gateway observers
Messaging::SubscriptionManager.create do |m|

  m.add :autoresponder, Autoresponder.new
  # m.add :inventory, Inventory.new
  # m.add :billing, Billing.new
  # m.add :shipping, Shipping.new

  #start subscriptions
  m.start
end