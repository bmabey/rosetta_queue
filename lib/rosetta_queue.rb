require 'activesupport' # TODO: remove dependency

$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__))) unless $LOAD_PATH.include?(File.expand_path(File.dirname(__FILE__)))

Dir[File.join(File.dirname(__FILE__), "rosetta_queue/*.rb")].each do |file|
  require file
end
#require 'rosetta_queue/core'
                               
