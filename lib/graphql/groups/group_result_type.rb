# frozen_string_literal: true

require 'graphql'

require 'graphql/groups/group_field'

module GraphQL
  module Groups
    class GroupResultType < GraphQL::Schema::Object
      alias group_result object

      class << self
        def define_aggregate(name, **options, &block)
          field :key, String, null: false, **options, &block

          define_method name do
            group_result[1][:name]
          end
        end
      end

      field :key, String, null: false

      field :count, Integer, null: false

      field :avg, Integer, null: false

      field :min, Integer, null: false

      field :max, Integer, null: false

      field :group_by, self, null: false, camelize: true

      def key
        group_result[0]
      end

      def count
        group_result[1][:count]
      end

      def avg
        group_result[1][:avg]
      end

      def min
        group_result[1][:min]
      end

      def max
        group_result[1][:max]
      end

      def sum
        group_result[1][:sum]
      end

      def group_by
        group_result[1][:nested]
      end
    end
  end
end
