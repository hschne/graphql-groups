require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task default: :spec

desc 'Show benchmark results'
task :benchmark do
  require_relative 'benchmark/benchmark'

  Compare.new.run
end
