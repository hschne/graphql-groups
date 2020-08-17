# frozen_string_literal: true

require 'graphql'
require 'graphql/groups'

require_relative 'db'
require_relative 'models'
require 'groupdate'

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

  by :list_price

  def published_at(scope:, interval:)
    case interval
    when 'month'
      scope.group("strftime('%Y-%m-01 00:00:00 UTC', published_at)")
    when 'year'
      scope.group("strftime('%Y-01-01 00:00:00 UTC', published_at)")
    else
      scope.group("strftime('%Y-%m-%d 00:00:00 UTC', published_at)")
    end
  end

  def list_price(scope:)
    currency = context[:currency] || ' $'
    scope.group("list_price || ' #{currency}'")
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
