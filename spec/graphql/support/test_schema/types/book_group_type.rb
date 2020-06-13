# frozen_string_literal: true

require 'graphql/groups'

class BookGroupType < GraphQL::Groups::Schema::GroupType
  scope { Book.all }

  by :published_at do
    argument :interval, String, required: false
    with { |scope, args| published_group(scope, args) }
  end

  private

  def published_group(scope, args)
    case args[:interval]
    when 'month'
      scope.group_by_month
    when 'week'
      scope.group_by_week
    else
      scope.group_by_day
    end
  end
end
