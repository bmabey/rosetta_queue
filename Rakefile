require 'rubygems'
require 'active_record'
require 'yaml'
require 'spec'

namespace :db do

  task :default => :migrate

  desc "Migrate the database through scripts in db/migrate. Target specific version with VERSION=x"

  task :environment do
    ActiveRecord::Base.configurations = YAML::load(File.open('config/database.yml'))
    ActiveRecord::Base.establish_connection :"#{ENV["ETL_ENV"]}"
    ActiveRecord::Base.logger = Logger.new(File.open('config/database.log', 'a'))
  end

  task :migrate do
    ENV["ETL_ENV"] = "production" unless ENV["ETL_ENV"]
    ActiveRecord::Base.configurations = YAML::load(File.open('config/database.yml'))
    ActiveRecord::Base.establish_connection :"#{ENV["ETL_ENV"]}"
    ActiveRecord::Base.logger = Logger.new(File.open('config/database.log', 'a'))
    ActiveRecord::Migrator.migrate('db/migrate', ENV["VERSION"] ? ENV["VERSION"].to_i : nil)
  end

  desc "Dropping database"
  task :drop => :environment do
   db_config = ActiveRecord::Base.configurations["#{ENV["ETL_ENV"]}"]["database"]
   sql = "DROP DATABASE IF EXISTS `#{db_config}`"
   ActiveRecord::Base.connection.execute(sql)
  end  

  desc "Creating database"
  task :create => :environment do
   db_config = ActiveRecord::Base.configurations["#{ENV["ETL_ENV"]}"]["database"]
   sql = "CREATE DATABASE `#{db_config}`"
   ActiveRecord::Base.connection.execute(sql)
  end

  desc 'Loading dimension data for warehouse.'
  task :load_data => :environment do
    Dir.entries('scripts/builds').each do |file|
      ruby "scripts/builds/#{file}" if(file.match(/[a-zA-Z].rb$/))
    end
  end

  desc 'Load dimension data.'
  task :load_build => :environment do
    unless (build_file = ARGV[1]).nil?
      ruby "scripts/builds/#{build_file}"
    else
      puts "you must pass a build file as an argument for this to work."
    end
  end

  # primary rebuid tasks
  namespace :rebuild do

    namespace :dev do

      task :set_env do
        ENV["ETL_ENV"] = "development"
      end
      
      task :prepare_db => ['set_env', 'db:rebuild:actions', 'db:load_data']
    end

    namespace :test do
      
      task :set_env do
        ENV["ETL_ENV"] = "test"
      end

      task :prepare_db => ['set_env', 'db:rebuild:actions']
    end

    desc 'Drops, creates and then migrates the database for the current environment.'
    task :actions => ['db:drop', 'db:create', 'db:migrate']

    task :test => ['test:prepare_db']
    task :dev => ['dev:prepare_db']
    task :all => ['test:prepare_db', 'dev:prepare_db']
  end
end

namespace :setup do
  
  desc "run activemq in the background"
  task :activemq do
    system "~/activemq/bin/activemq &"
  end

end