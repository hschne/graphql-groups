# frozen_string_literal: true

require 'graphql'

class BaseType < GraphQL::Schema::Object; end

class AuthorType < BaseType
  field :name, String, null: false
  field :age, Int, null: false
end

class BookType < BaseType
  field :name, String, null: false
end

class QueryType < BaseType
  field :authors, [AuthorType], null: false

  def authors
    Author.all
  end
end

class GroupsSchema < GraphQL::Schema
  query QueryType

  def self.resolve_type(_type, obj, _ctx)
    "#{obj.class.name}Type"
  end
end
