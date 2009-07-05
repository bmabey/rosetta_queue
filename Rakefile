require 'rubygems'
require 'spec/rake/spectask'
require 'cucumber/rake/task'
 
Cucumber::Rake::Task.new do |t|
  t.cucumber_opts = "--format pretty"
end   

desc "Run the specs under spec"
Spec::Rake::SpecTask.new do |t|
  t.spec_opts = ['--options', "spec/spec.opts"]
  t.spec_files = FileList['spec/**/*_spec.rb']
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name = "rosetta_queue"
    s.rubyforge_project = "rosetta-queue"
    s.summary = %Q{Messaging gateway API with adapters for many messaging systems available in Ruby.}
    s.email = "ben@benmabey.com"
    s.homepage = "http://github.com/bmabey/rosetta_queue"
    s.description = %Q{Messaging gateway API with adapters for many messaging systems available in Ruby. Messaging systems can be easily switched out with a small configuration change. Code for testing on the object and application level is also provided.}
    s.extra_rdoc_files = ["README.rdoc", "MIT-LICENSE.txt"]
    s.files = FileList["[A-Z]*.*", "{bin,generators,lib,features,spec}/**/*", "Rakefile", "cucumber.yml"]
    s.authors = ["Ben Mabey", "Chris Wyckoff"]
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

desc "Default task runs specs"
task :default => [:spec]