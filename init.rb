%w[exceptions ext messaging modules].each do |file|
  require File.join(File.dirname(__FILE__), "lib", file)
end

if Rails.env == "test"
  Dir[File.join(File.dirname(__FILE__), 'lib', 'messaging', 'spec_helpers/*.rb')].each do |file|
    require file
  end
end