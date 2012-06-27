require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'cucumber/rake/task'
require 'yard'

task :default => [:test]

desc 'Run all the features and specs'
task :test    => [:rspec, :cucumber]

RSpec::Core::RakeTask.new(:rspec) do |t|
  t.rspec_opts = %w{ --color --format=progress --require spec/spec_helper.rb }
end

Cucumber::Rake::Task.new(:cucumber) do |t|
  t.cucumber_opts = '--format progress'
end

YARD::Rake::YardocTask.new

desc 'Generate test coverage report'
task :coverage do
  ENV['COVERAGE'] = 'true'
  Rake::Task[:rspec].execute
  Rake::Task[:cucumber].execute
end
