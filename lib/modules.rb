Dir[File.join(File.dirname(__FILE__), "modules/*.rb")].each do |file|
  require file
end