require "bundler/gem_tasks"
require 'rspec/core/rake_task'

####
# Building the gem and generating documentation.
####

require 'dlss/rake/dlss_release'
Dlss::Release.new

def app_version
  return File.read('VERSION').match('[\w\.]+')[0]
end

desc 'Get application version'
task :app_version do   # Task is needed by the dlss_release task.
  puts app_version()
end

desc 'DLSS release and push to Rubygems'
task :full_release do
  Rake::Task["dlss_release"].invoke
  Rake::Task["gem_push"].invoke
end

desc 'Push gem to Rubygems'
task :gem_push do
  system "gem push pkg/dir_validator-#{app_version}.gem"
end


####
# Generating documentation.
####

desc 'Generate YARD documentation'
task :doc do
  system 'yard doc'
end


####
# Running tests.
####

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
