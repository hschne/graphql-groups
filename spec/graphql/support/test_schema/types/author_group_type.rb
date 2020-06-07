# frozen_string_literal: true

require_relative 'author_group_result_type'

class AuthorGroupType < BaseType
  alias group object

  field :age, [AuthorGroupResultType], null: false

  def age
    group[:age]
  end
end
