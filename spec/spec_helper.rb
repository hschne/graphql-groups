# frozen_string_literal: true

require 'bundler/setup'
require 'graphql/groups'
require 'database_cleaner/active_record'
require 'gqli/dsl'

Dir["#{File.dirname(__FILE__)}/graphql/support/**/*.rb"].sort.each { |f| require f }

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

  config.before :each do
    DatabaseCleaner.strategy = :transaction
  end

  config.before :each do
    DatabaseCleaner.start
  end

  config.after :each do
    DatabaseCleaner.clean
  end
end
