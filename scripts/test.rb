require File.dirname(__FILE__) + '/../config/loader.rb'

class Autoresponder
  include Consumeable

  subscribes_to :autoresponder
  options :persistent => false, :ack => "client"

  def on_message(message)
     puts "sending email for message '#{message}'"
  end
end

