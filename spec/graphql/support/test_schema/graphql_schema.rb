# frozen_string_literal: true

require 'graphql'

class BaseType < GraphQL::Schema::Object; end

require_relative 'types/author_group_type'

class QueryType < BaseType

  field :groups, AuthorGroupType, null: false, extras: [:lookahead]

  def authors
    Author.all
  end

  def groups(lookahead:)
    query = GraphQL::Groups::LookaheadParser.parse(lookahead)
    GraphQL::Groups::QueryExecutor.new.run(Author.all, query)
  end
end

class GroupsSchema < GraphQL::Schema
  query QueryType

  def self.resolve_type(_type, obj, _ctx)
    "#{obj.class.name}Type"
  end
end
