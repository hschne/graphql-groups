# frozen_string_literal: true

require 'graphql/groups'

class AuthorGroupResultType < GraphQL::Groups::GroupResultType
  field :hey, String, null:false
  aggregate :average do
    attribute :age
    with { |scope, attribute| scope.average(attribute) }
  end
end
