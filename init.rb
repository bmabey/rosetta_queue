require 'rubygems'
require 'activesupport'

%w[modules exceptions ext rosetta_queue].each do |file|
  require File.join(File.dirname(__FILE__), "lib", file)
end

if Object.const_defined?("Rails") && Rails.env != "production"
  Dir[File.join(File.dirname(__FILE__), 'lib', 'rosetta_queue', 'spec_helpers/*.rb')].each do |file|
    require file
  end
end