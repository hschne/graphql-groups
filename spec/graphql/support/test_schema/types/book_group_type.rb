# frozen_string_literal: true

require 'graphql/groups'

class BookGroupType < GraphQL::Groups::Schema::GroupType
  scope { object }

  by :name

  by :published_at do
    argument :interval, String, required: false
  end

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
end
