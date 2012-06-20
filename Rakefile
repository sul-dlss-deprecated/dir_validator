require "bundler/gem_tasks"
require 'dlss/rake/dlss_release'

desc 'Get application version'
task :app_version do
  puts File.read(File.expand_path('../VERSION', __FILE__)).match('[\w\.]+')[0]
end

# Dlss::Release.new
