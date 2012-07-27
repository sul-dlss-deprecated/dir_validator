require "bundler/gem_tasks"
require 'dlss/rake/dlss_release'
require 'rspec/core/rake_task'

desc 'Get application version'
task :app_version do
  puts File.read(File.expand_path('../VERSION', __FILE__)).match('[\w\.]+')[0]
end

desc 'Build gem'
task :build do
  system 'gem build dir_validator.gemspec'
end

desc 'Generate documentation'
task :docs do
  system 'yard doc - bin/* LICENSE.*'
end

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
