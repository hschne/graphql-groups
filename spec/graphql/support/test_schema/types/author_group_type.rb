# frozen_string_literal: true

require 'graphql/groups'
require_relative 'author_group_result_type'

class AuthorGroupType < GraphQL::Groups::GroupType
  scope { Author.all }

  result_type { AuthorGroupResultType }

  by :name

  by :age do
    with { |scope| scope.group("(cast(age/10 as int) * 10) || '-' || ((cast(age/10 as int) + 1) * 10)")}
  end
end
