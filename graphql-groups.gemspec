lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'graphql/groups/version'

Gem::Specification.new do |spec|
  spec.name          = 'graphql-groups'
  spec.version       = Graphql::Groups::VERSION
  spec.authors       = ['Hans-Jörg Schnedlitz']
  spec.email         = ['hans.schnedlitz@gmail.com']

  spec.summary       = 'A short summary'
  spec.description   = 'A description'
  spec.homepage      = 'http://graphqlgroups.com'
  spec.license       = 'MIT'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/hschne/graphql-groups'
  spec.metadata['changelog_uri'] = 'https://github.com/hschne/graphql-groups/CHANGELOG'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'activerecord', '~> 5.0'
  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'database_cleaner-active_record'
  spec.add_development_dependency 'gqli'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 0.88'
  spec.add_development_dependency 'rubocop-rspec', '~> 1.42'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'sqlite3', '~> 1.4.2'

  spec.add_dependency 'graphql', '~> 1', '> 1.9'
end
