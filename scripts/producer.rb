require File.dirname(__FILE__) + '/../config/loader.rb'

class TestProducer < Messaging::Producer
  
  publishes_to :sale
  options :persistent => false
  
end

t = TestProducer.new
t.publish({"foo" => "bar"}.to_json)

# Messaging::Producer.publish(:sale, {"foo" => "bar"}.to_json, :persistent => false)

# Messaging::Producer.publish(:autoresponder, {"foo" => "bar"}.to_json, :persistent => false)
# Messaging::Producer.publish(:autoresponder, {"foo" => "bar"}.to_json, :persistent => false)
# 
# Messaging::Producer.publish(:billing, {"baz" => "boo"}.to_json, :persistent => false)
# Messaging::Producer.publish(:billing, {"baz" => "boo"}.to_json, :persistent => false)
# 
# Messaging::Producer.publish(:shipping, {"baz" => "boo"}.to_json, :persistent => false)
# Messaging::Producer.publish(:shipping, {"baz" => "boo"}.to_json, :persistent => false)