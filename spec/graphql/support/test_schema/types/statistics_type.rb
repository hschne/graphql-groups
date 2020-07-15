# frozen_string_literal: true

class StatisticsType < BaseType
  include GraphQL::Groups

  group :books, BookGroupType
end
