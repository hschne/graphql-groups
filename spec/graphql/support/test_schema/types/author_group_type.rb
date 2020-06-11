# frozen_string_literal: true

require 'graphql/groups'

class AuthorGroupType < GraphQL::Groups::GroupType
  scope { Author.all }

  by :name

  by :age do
    with { |scope| scope.group("(cast(age/10 as int) * 10) || '-' || ((cast(age/10 as int) + 1) * 10)")}
  end
end
