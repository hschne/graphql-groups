# frozen_string_literal: true

require 'graphql'
require 'graphql/groups'
require 'groupdate'

require_relative 'db'
require_relative 'models'

class AuthorGroupResultType < GraphQL::Groups::Schema::GroupResultType
  aggregate :average do
    attribute :age
  end

  def average(scope:, attribute:)
    scope.average(attribute)
  end
end

class AuthorGroupType < GraphQL::Groups::Schema::GroupType
  scope { Author.all }

  result_type { AuthorGroupResultType }

  by :name

  by :age

  def age(scope:)
    scope.group("(cast(age/10 as int) * 10) || '-' || ((cast(age/10 as int) + 1) * 10)")
  end
end

class BookGroupType < GraphQL::Groups::Schema::GroupType
  scope { object }

  by :name

  by :published_at do
    argument :interval, String, required: false
  end

  def published_at(scope:, interval:)
    scope.group_by_period(interval.to_sym, :published_at)
  end
end

class StatisticsType < GraphQL::Schema::Object
  include GraphQL::Groups

  group :books, BookGroupType
end

class QueryType < GraphQL::Schema::Object
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
