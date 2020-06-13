# frozen_string_literal: true

require 'graphql'

module GraphQL
  module Groups
    module Schema
      class GroupResultType < GraphQL::Schema::Object
        include Aggregates

        alias group_result object

        field :key, String, null: false

        field :count, Integer, null: false

        field :group_by, self, null: false, camelize: true

        aggregate_field :count, Integer, null: false do
          with { |scope, _| scope.size }
        end

        def key
          group_result[0]
        end

        def count
          group_result[1][:count]
        end

        def group_by
          group_result[1][:nested]
        end
      end
    end
  end
end
