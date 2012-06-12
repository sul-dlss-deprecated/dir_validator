$LOAD_PATH.push File.expand_path("../lib", __FILE__)

require 'dir_validator/version'

Gem::Specification.new do |s|

  s.name              = 'dir_validator'
  s.rubyforge_project = 'dir_validator'
  s.version           = DirValidator::VERSION
  s.authors           = ['Monty Hindman']
  s.email             = ['hindman@stanford.edu']
  s.homepage          = ''
  s.summary           = %q{...}
  s.description       = %q{...}
  s.require_paths     = ['lib']
  s.files             = `git ls-files`.split("\n")
  s.test_files        = `git ls-files -- {spec}/*`.split("\n")
  s.executables       = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }

  s.add_development_dependency 'rspec', '~> 2.6'
  s.add_development_dependency 'lyberteam-devel'
  s.add_development_dependency 'yard'
  s.add_development_dependency 'awesome_print'
  s.add_development_dependency 'looksee'
  
end
