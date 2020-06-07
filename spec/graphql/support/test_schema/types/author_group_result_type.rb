# frozen_string_literal: true

require_relative 'author_group_type'

class AuthorGroupResultType < BaseType
  alias group object

  field :key, String, null: false

  field :count, Integer, null: false

  field :group_by, self, null: false, camelize: true

  def key
    group[0]
  end

  def count
    group[1][:count]
  end

  def group_by
    group[1][:nested]
  end
end
