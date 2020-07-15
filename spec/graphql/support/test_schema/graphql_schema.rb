# frozen_string_literal: true

require 'graphql'
require 'graphql/groups'

class BaseType < GraphQL::Schema::Object; end

require_relative 'models'
require_relative 'types/book_group_type'
require_relative 'types/author_group_type'
require_relative 'types/statistics_type'

class QueryType < BaseType
  include GraphQL::Groups

  group :author_groups, AuthorGroupType

  field :statistics, StatisticsType, null: false

  def statistics
    Book.all
  end
end

class GroupsSchema < GraphQL::Schema
  query QueryType

  def self.resolve_type(_type, obj, _ctx)
    "#{obj.class.name}Type"
  end
end
