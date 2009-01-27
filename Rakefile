require 'rubygems'
require 'active_record'
require 'yaml'
require 'spec'
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

