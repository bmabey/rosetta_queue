require File.dirname(__FILE__) + '/../config/loader.rb'

Messaging::Producer.publish(:autoresponder, {"foo" => "bar"}.to_json, :persistent => false)