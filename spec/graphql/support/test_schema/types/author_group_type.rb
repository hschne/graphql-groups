# frozen_string_literal: true

require 'graphql/groups'

class AuthorGroupType < GraphQL::Groups::GroupType
  scope { Author.all }

  by :age do
    query { |scope| scope.group(:age) }
  end

  by :name
end
