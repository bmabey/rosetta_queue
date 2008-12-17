Dir[File.join(File.dirname(__FILE__), "consumer_managers/*.rb")].each do |file|
  require file
end
