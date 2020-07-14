# frozen_string_literal: true

require 'graphql/groups'

class AuthorGroupResultType < GraphQL::Groups::Schema::GroupResultType
  aggregate :average do
    attribute :age
  end

  def average(scope:, attribute:)
    scope.average(attribute)
  end
end
