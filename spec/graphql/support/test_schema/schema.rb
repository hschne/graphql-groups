# frozen_string_literal: true

require 'active_record'

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: 'test.db'
)

class CreateAuthorsTable < ActiveRecord::Migration[5.2]
  def change
    create_table :authors do |table|
      table.string :name
      table.integer :age
      table.timestamps
    end
  end
end

class CreateBooksTable < ActiveRecord::Migration[5.2]
  def change
    create_table :books do |table|
      table.string :genre
      table.integer :author_id
      table.timestamps
    end
  end
end


