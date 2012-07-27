$LOAD_PATH.push File.expand_path("../lib", __FILE__)

vers = File.read(File.expand_path('../VERSION', __FILE__)).match('[\w\.]+')[0]

Gem::Specification.new do |s|
  s.name    = 'dir_validator'
  s.version = vers

  s.authors  = ['Monty Hindman']
  s.email    = ['hindman@stanford.edu']
  s.homepage = "https://github.com/sul-dlss"

  s.summary     = "Validate content of a directory structure."
  s.description = "This gem provides a convenient syntax for checking whether the " +
                  "contents of a directory structure match your expectations."

  s.require_paths = ['lib']
  s.files = Dir.glob("lib/**/*") + %w(
    LICENSE.rdoc
    README.rdoc
    CHANGELOG.rdoc
  )

  s.add_development_dependency 'rspec', '~> 2.6'
  s.add_development_dependency 'lyberteam-devel'
  s.add_development_dependency 'yard'
  s.add_development_dependency 'awesome_print'
  s.add_development_dependency 'looksee'
  s.add_development_dependency 'rcov'
end
