# frozen_string_literal: true

require 'graphql'

require 'graphql/groups/group_field'

module GraphQL
  module Groups
    class AggregateType < GraphQL::Schema::Object
      alias aggregate object
    end
  end
end
