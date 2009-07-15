# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{rosetta_queue}
  s.version = "0.1.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Ben Mabey", "Chris Wyckoff"]
  s.date = %q{2009-07-14}
  s.description = %q{Messaging gateway API with adapters for many messaging systems available in Ruby. Messaging systems can be easily switched out with a small configuration change. Code for testing on the object and application level is also provided.}
  s.email = %q{ben@benmabey.com}
  s.extra_rdoc_files = [
    "MIT-LICENSE.txt",
     "README.rdoc"
  ]
  s.files = [
    "History.txt",
     "MIT-LICENSE.txt",
     "README.rdoc",
     "Rakefile",
     "VERSION.yml",
     "cucumber.yml",
     "features/filtering.feature",
     "features/messaging/point_to_point.feature",
     "features/messaging/step_definitions/point_to_point_steps.rb",
     "features/messaging/step_definitions/publish_subscribe_steps.rb",
     "features/step_definitions/filtering_steps.rb",
     "features/support/common_messaging_steps.rb",
     "features/support/env.rb",
     "features/support/sample_consumers.rb",
     "lib/rosetta_queue.rb",
     "lib/rosetta_queue/adapter.rb",
     "lib/rosetta_queue/adapters/amqp.rb",
     "lib/rosetta_queue/adapters/base.rb",
     "lib/rosetta_queue/adapters/beanstalk.rb",
     "lib/rosetta_queue/adapters/fake.rb",
     "lib/rosetta_queue/adapters/null.rb",
     "lib/rosetta_queue/adapters/stomp.rb",
     "lib/rosetta_queue/base.rb",
     "lib/rosetta_queue/consumer.rb",
     "lib/rosetta_queue/consumer_managers/base.rb",
     "lib/rosetta_queue/consumer_managers/evented.rb",
     "lib/rosetta_queue/consumer_managers/threaded.rb",
     "lib/rosetta_queue/core_ext/string.rb",
     "lib/rosetta_queue/destinations.rb",
     "lib/rosetta_queue/exceptions.rb",
     "lib/rosetta_queue/filters.rb",
     "lib/rosetta_queue/logger.rb",
     "lib/rosetta_queue/message_handler.rb",
     "lib/rosetta_queue/producer.rb",
     "lib/rosetta_queue/spec_helpers.rb",
     "lib/rosetta_queue/spec_helpers/hash.rb",
     "lib/rosetta_queue/spec_helpers/helpers.rb",
     "lib/rosetta_queue/spec_helpers/publishing_matchers.rb",
     "spec/rosetta_queue/adapter_spec.rb",
     "spec/rosetta_queue/adapters/amqp_spec.rb",
     "spec/rosetta_queue/adapters/beanstalk_spec.rb",
     "spec/rosetta_queue/adapters/fake_spec.rb",
     "spec/rosetta_queue/adapters/null_spec.rb",
     "spec/rosetta_queue/adapters/shared_adapter_behavior.rb",
     "spec/rosetta_queue/adapters/shared_fanout_behavior.rb",
     "spec/rosetta_queue/adapters/stomp_spec.rb",
     "spec/rosetta_queue/consumer_managers/evented_spec.rb",
     "spec/rosetta_queue/consumer_managers/shared_manager_behavior.rb",
     "spec/rosetta_queue/consumer_managers/threaded_spec.rb",
     "spec/rosetta_queue/consumer_spec.rb",
     "spec/rosetta_queue/core_ext/string_spec.rb",
     "spec/rosetta_queue/destinations_spec.rb",
     "spec/rosetta_queue/filters_spec.rb",
     "spec/rosetta_queue/producer_spec.rb",
     "spec/rosetta_queue/shared_messaging_behavior.rb",
     "spec/spec.opts",
     "spec/spec_helper.rb"
  ]
  s.homepage = %q{http://github.com/bmabey/rosetta_queue}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{rosetta-queue}
  s.rubygems_version = %q{1.3.3}
  s.summary = %q{Messaging gateway API with adapters for many messaging systems available in Ruby.}
  s.test_files = [
    "spec/rosetta_queue/adapter_spec.rb",
     "spec/rosetta_queue/adapters/amqp_spec.rb",
     "spec/rosetta_queue/adapters/beanstalk_spec.rb",
     "spec/rosetta_queue/adapters/fake_spec.rb",
     "spec/rosetta_queue/adapters/null_spec.rb",
     "spec/rosetta_queue/adapters/shared_adapter_behavior.rb",
     "spec/rosetta_queue/adapters/shared_fanout_behavior.rb",
     "spec/rosetta_queue/adapters/stomp_spec.rb",
     "spec/rosetta_queue/consumer_managers/evented_spec.rb",
     "spec/rosetta_queue/consumer_managers/shared_manager_behavior.rb",
     "spec/rosetta_queue/consumer_managers/threaded_spec.rb",
     "spec/rosetta_queue/consumer_spec.rb",
     "spec/rosetta_queue/core_ext/string_spec.rb",
     "spec/rosetta_queue/destinations_spec.rb",
     "spec/rosetta_queue/filters_spec.rb",
     "spec/rosetta_queue/producer_spec.rb",
     "spec/rosetta_queue/shared_messaging_behavior.rb",
     "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
