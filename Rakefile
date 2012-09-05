require 'bundler'
require "bundler/gem_tasks"
require 'rspec/core/rake_task'

## Bundler setup ##

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end


## Running tests ##

task(:default => [:rspec])

def rspec_config(tag = nil)
  opts = ["-c", "-f doc"]
  opts.push(tag) if tag
  return lambda { |spec|
    spec.rcov       = true if ENV['COVERAGE'] and RUBY_VERSION =~ /^1.8/
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


## Other ##

desc "Open an irb session preloaded with this library"
task :console do
  system "irb -rubygems -I lib -r dir_validator.rb"
end

desc "Generate Yard documentation"
task :doc do
  system "yard"
end
