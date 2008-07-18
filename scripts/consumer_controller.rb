require 'rubygems'
require 'daemons'

# To use the data mart ETL consumer application 'consumer_app.rb' in a production environment, you need to be able to run 
# consumer_app.rb in the background (this means detach it from the console, fork it in the background, release all 
# directories and file descriptors).
# 
# Just create consumer_controller.rb like this:
# 
#   # this is consumer_controller.rb
# 
#   require 'rubygems'        # if you use RubyGems
#   require 'daemons'
# 
#   Daemons.run('consumer_app.rb')
# 
# And use it like this from the console:
# 
#   $ ruby consumer_controller.rb start
#       (consumer_app.rb is now running in the background)
#   $ ruby consumer_controller.rb restart
#       (...)
#   $ ruby consumer_controller.rb stop


if(ARGV[1])
  daemonizeable_resource = ARGV[1]

  APP_ROOT  = File.expand_path(File.dirname(__FILE__) + '/..')
  LOG_ROOT  = File.expand_path(File.dirname(__FILE__) + '/../../tmp')
  # LOG_ROOT  = File.dirname(__FILE__) + '/../../tmp' unless defined?(LOG_ROOT)

  script_file = File.join(File.expand_path(APP_ROOT),"messages","#{daemonizeable_resource}.rb")
  log_dir = File.join(File.expand_path(LOG_ROOT), "#{daemonizeable_resource}")

  options = {
    :app_name   => "#{daemonizeable_resource}_controller",
    :dir_mode   => :normal,
    :dir        => log_dir,
    :multiple   => true,
    :ontop      => false,
    :mode       => :load,
    :backtrace  => true,
    :monitor    => true,
    :log_output => true
  }

  Daemons.run(script_file, options)
else
  puts "Unable to daemonize application.  Missing a target file..."
end