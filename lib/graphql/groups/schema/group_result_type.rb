# frozen_string_literal: true

require 'graphql'
require 'graphql/groups/schema/group_type'

module GraphQL
  module Groups
    module Schema
      class GroupResultType < GraphQL::Schema::Object
        include Aggregates

        alias group_result object

        field :key, String, null: false

        field :count, Integer, null: false

        aggregate_field :count, Integer, null: false, query_method: :count, resolver_method: :resolve_count

        def key
          group_result[0]
        end

        def count(scope:, **_)
          scope.size
        end

        def resolve_count
          group_result[1][:count]
        end

        private

        def inner_result_type
          @inner_result_type ||= self
        end
      end
    end
  end
end
