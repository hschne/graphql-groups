# frozen_string_literal: true

require 'graphql/groups'

class AuthorGroupResultType < GraphQL::Groups::Schema::GroupResultType
  aggregate :average do
    attribute :age
    with { |scope, attribute| scope.average(attribute) }
  end
end
