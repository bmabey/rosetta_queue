# -*- encoding: utf-8 -*-
Gem::Specification.new do |s|
  s.name = %q{rosetta_queue}
  s.version = "0.2.2"
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Ben Mabey", "Chris Wyckoff"]
  s.date = %q{2009-01-28}
  s.description = %q{Messaging gateway API with adapters for many messaging systems available in Ruby. Messaging systems can be easily switched out with a small configuration change. Code for testing on the object and application level is also provided.}
  s.email = %q{ben@benmabey.com}
  s.extra_rdoc_files = ["README.rdoc", "MIT-LICENSE.txt"]
  s.files = ["History.txt", 
  	    "MIT-LICENSE.txt", 
	    "README.rdoc", 
	    "VERSION.yml", 
	    "lib/rosetta_queue", 
	    "lib/rosetta_queue/adapter.rb", 
	    "lib/rosetta_queue/adapters", 
	    "lib/rosetta_queue/adapters/amqp.rb", 
	    "lib/rosetta_queue/adapters/base.rb", 
	    "lib/rosetta_queue/adapters/fake.rb", 
	    "lib/rosetta_queue/adapters/null.rb", 
	    "lib/rosetta_queue/adapters/stomp.rb", 
	    "lib/rosetta_queue/base.rb", 
	    "lib/rosetta_queue/consumer.rb", 
	    "lib/rosetta_queue/consumer_managers", 
	    "lib/rosetta_queue/consumer_managers/base.rb", 
	    "lib/rosetta_queue/consumer_managers/evented.rb", 
	    "lib/rosetta_queue/consumer_managers/threaded.rb", 
	    "lib/rosetta_queue/destinations.rb", 
	    "lib/rosetta_queue/exceptions.rb", 
	    "lib/rosetta_queue/filters.rb", 
	    "lib/rosetta_queue/logger.rb", 
	    "lib/rosetta_queue/message_handler.rb", 
	    "lib/rosetta_queue/producer.rb", 
	    "lib/rosetta_queue/spec_helpers", 
	    "lib/rosetta_queue/spec_helpers/hash.rb", 
	    "lib/rosetta_queue/spec_helpers/helpers.rb", 
	    "lib/rosetta_queue/spec_helpers/publishing_matchers.rb", 
	    "lib/rosetta_queue/spec_helpers.rb", 
	    "lib/rosetta_queue.rb", 
             "Rakefile",
             "cucumber.yml"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/bmabey/rosetta_queue}
  s.rdoc_options = ["--inline-source", "--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{rosetta-queue}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Messaging gateway API with adapters for many messaging systems available in Ruby.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
