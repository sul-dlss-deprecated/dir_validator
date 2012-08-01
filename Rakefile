require "bundler/gem_tasks"
require 'rspec/core/rake_task'

task :default => [:rspec]

def rspec_config(tag = nil)
  opts = ["-c", "-f doc"]
  opts << tag if tag
  return lambda { |spec|
    spec.rcov       = true
    spec.rcov_opts  = ["--exclude /gems/,spec/"]
    spec.rspec_opts = opts
  }
end

desc "Run all tests"
RSpec::Core::RakeTask.new(:rspec, &rspec_config())

desc "Run unit tests"
RSpec::Core::RakeTask.new(:rspec_unit, &rspec_config("--tag ~integration"))

desc "Run integration tests"
RSpec::Core::RakeTask.new(:rspec_int, &rspec_config("--tag integration"))
