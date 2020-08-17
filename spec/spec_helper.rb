# frozen_string_literal: true

require 'simplecov'
SimpleCov.start

require 'bundler/setup'
require 'graphql/groups'
require 'database_cleaner/active_record'
require 'gqli/dsl'

Dir["#{File.dirname(__FILE__)}/graphql/support/**/*.rb"].sort.each { |f| require f }

require 'test-prof'
TestProf.configure do |config|
  config.output_dir = 'tmp/test_prof'
  config.timestamps = true
  config.color = true
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before :suite do
    CreateAuthorsTable.migrate(:up) unless ActiveRecord::Base.connection.table_exists?('authors')
    CreateBooksTable.migrate(:up) unless ActiveRecord::Base.connection.table_exists?('books')
    DatabaseCleaner.clean_with :truncation
  end

  config.before do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.start
  end

  config.after do
    DatabaseCleaner.clean
  end
end
