# frozen_string_literal: true

require 'graphql/groups'

class AuthorGroupResultType < GraphQL::Groups::GroupResultType

  aggregate :avg do
    attribute :age
    with { |scope, attribute| scope.average(attribute) }
  end
end
