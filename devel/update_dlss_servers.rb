#! /usr/bin/env ruby

# Update the dir_validate gem on the SUL-DLSS servers.

envs     = %w(dev test prod)
gem_name = 'dir_validator'
cmd      = [
  "rvm use 1.8.7@validate-dir --create",
  "gem install #{gem_name}",
  "gem cleanup #{gem_name}",
].join(' && ')


envs.each do |env|
  host = "sul-lyberservices-#{env}.stanford.edu"
  puts "\n========\n#{host}"
  system "ssh lyberadmin@#{host} '#{cmd}'"
end
