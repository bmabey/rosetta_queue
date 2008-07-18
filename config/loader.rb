require 'rubygems'
require 'active_record'
require 'active_support'
require 'net/smtp'
require 'yaml'
require 'stomp'

#set constants
ENV["MESSAGING_ENV"]  = "development" unless ENV["MESSAGING_ENV"]
ROOT                  = File.dirname(__FILE__) + "/.." unless defined?(ROOT)
LOG_ROOT              = File.dirname(__FILE__) + "/../tmp" unless defined?(LOG_ROOT)
PORT                  = 61613 unless defined?(PORT)
HOST                  = "localhost" unless defined?(HOST)
USER                  = "" unless defined?(USER)
PASSWORD              = "" unless defined?(PASSWORD)

#load database environment
ActiveRecord::Base.configurations = YAML::load(File.open(ROOT+'/config/database.yml'))
ActiveRecord::Base.establish_connection :"#{ENV["MESSAGING_ENV"]}"

#load libraries
require ROOT + "/lib/modules.rb"
require ROOT + "/lib/exceptions.rb"
require ROOT + "/lib/ext.rb"
require ROOT + "/lib/messaging.rb"

# map queues
Messaging::Destinations.define do |queue|
  # queue.map :test_queue, '/queue/test_queue'
end
