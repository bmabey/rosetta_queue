Dir[File.join(File.dirname(__FILE__), "messaging/*.rb")].each do |file|
  require file
end