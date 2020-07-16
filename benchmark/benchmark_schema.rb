# frozen_string_literal: true

require 'graphql'
require 'graphql/groups'

class BaseType < GraphQL::Schema::Object; end

class AuthorGroupType < GraphQL::Groups::Schema::GroupType
  scope { Author.all }

  by :name
end

class SlowAuthorGroupResultType < GraphQL::Schema::Object
  field :key, String, null: false
  field :count, Integer, null: false

  def key
    object[0]
  end

  def count
    object[1].size
  end
end

class SlowAuthorGroupType < GraphQL::Schema::Object
  field :name, [SlowAuthorGroupResultType], null: false

  def name
    object.group_by(&:name)
  end
end

class QueryType < BaseType
  include GraphQL::Groups

  group :fast_groups, AuthorGroupType, camelize: true

  field :slow_groups, SlowAuthorGroupType, null: false, camelize: true

  def slow_groups
    Author.all
  end
end

class PerformanceSchema < GraphQL::Schema
  query QueryType

  def self.resolve_type(_type, obj, _ctx)
    "#{obj.class.name}Type"
  end
end
