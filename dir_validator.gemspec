proj_dir = File.expand_path('..', __FILE__)
vers     = File.read(File.join(proj_dir, 'VERSION')).match('[\w\.]+')[0]
$LOAD_PATH.unshift File.join(proj_dir, "lib")

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
    tutorial/tutorial.rb
    .yardopts
  )

  s.add_development_dependency 'rspec', '~> 2.6'
  s.add_development_dependency 'yard'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'awesome_print'

end
