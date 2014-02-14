require File.expand_path(File.join(File.dirname(__FILE__), 'lib', 'simple_gem', 'version'))

Gem::Specification.new do |s|

  # definition
  s.name = %q{simple_gem}
  s.version = SimpleGem::VERSION

  # details
  s.date = %q{2012-01-08}
  s.summary = %q{Support tools, libraries, and rake tasks for creating gems.}
  s.description = %q{Contains tools that create gem skeletons, rake tasks that support building and deploying gems, and more.}
  s.authors = [ 'David Dawson' ]
  s.email = %q{daws23@gmail.com}
  s.homepage = %q{https://github.com/daws/simple_gem}
  s.require_paths = [ 'lib' ]
  
  # documentation
  s.has_rdoc = true
  s.extra_rdoc_files = %w( README.rdoc CHANGELOG.rdoc LICENSE.txt )
  s.rdoc_options = %w( --main README.rdoc )

  # files to include
  s.files = Dir[ 'lib/**/*.rb', 'templates/**/*', 'README.rdoc', 'CHANGELOG.rdoc', 'LICENCE.txt' ]

  # dependencies
  s.add_dependency 'activesupport', '>= 3.0'
  s.add_dependency 'rake', '>= 0.8.7'

end
