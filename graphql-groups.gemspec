# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'graphql/groups/version'

Gem::Specification.new do |spec|
  spec.name = 'graphql-groups'
  spec.version = Graphql::Groups::VERSION
  spec.authors = ['Hans-Jörg Schnedlitz']
  spec.email = ['hans.schnedlitz@gmail.com']

  spec.summary = 'Create flexible and fast aggregation queries with graphql-ruby'
  spec.description = <<~HEREDOC
    GraphQL Groups makes it easy to add aggregation queries to your GraphQL schema. It combines a simple, flexible 
    schema definition with high performance
  HEREDOC
  spec.homepage = 'https://github.com/hschne/graphql-groups'
  spec.license = 'MIT'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/hschne/graphql-groups'
  spec.metadata['changelog_uri'] = 'https://github.com/hschne/graphql-groups/blob/master/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features|benchmark|.github)/}) }
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = Gem::Requirement.new('>= 2.6.0')

  spec.add_development_dependency 'activerecord', '~> 6.0'
  spec.add_development_dependency 'benchmark-ips', '~> 2.8'
  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'database_cleaner-active_record', '~> 1.8'
  spec.add_development_dependency 'gqli', '~> 1.0'
  spec.add_development_dependency 'groupdate', '~> 5.2.1'
  spec.add_development_dependency 'gruff', '~> 0.10'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 0.88'
  spec.add_development_dependency 'rubocop-rspec', '~> 1.42'
  spec.add_development_dependency 'simplecov', '~> 0.18.5'
  spec.add_development_dependency 'sqlite3', '~> 1.4.2'

  spec.add_dependency 'graphql', '~> 1', '> 1.9'
end
