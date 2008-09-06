require 'rubygems'
require 'active_record'
require 'active_support'
require 'net/smtp'
require 'yaml'

#set constants
ENV["MESSAGING_ENV"]  = "development" unless ENV["MESSAGING_ENV"]
MESSAGING_ROOT        = File.dirname(__FILE__) + "/.." unless defined?(MESSAGING_ROOT)
LOG_ROOT              = File.dirname(__FILE__) + "/../tmp" unless defined?(LOG_ROOT)

#load libraries
require MESSAGING_ROOT + "/lib/modules.rb"
require MESSAGING_ROOT + "/lib/exceptions.rb"
require MESSAGING_ROOT + "/lib/ext.rb"
require MESSAGING_ROOT + "/lib/messaging.rb"

Messaging::Adapter.define do |a|
  a.user      = ""
  a.password  = ""
  a.host      = "localhost"
  a.port      = 61613
  a.type      = "stomp"
end

# map queues
Messaging::Destinations.define do |queue|
  queue.map :autoresponder, '/queue/autoresponder'
end
