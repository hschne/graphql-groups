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
      table.integer :author_id
      table.string :name
      table.string :genre
      table.integer :list_price
      table.datetime :published_at
      table.timestamps
    end
  end
end


