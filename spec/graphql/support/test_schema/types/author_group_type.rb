# frozen_string_literal: true

require_relative 'author_group_result_type'
require 'graphql/groups'

class AuthorGroupType < GraphQL::Groups::GroupType

  by :age, AuthorGroupResultType
end
