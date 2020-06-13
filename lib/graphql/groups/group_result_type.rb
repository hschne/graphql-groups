# frozen_string_literal: true

require 'graphql'


module GraphQL
  module Groups
    class GroupResultType < GraphQL::Schema::Object
      alias group_result object
      def initialize(object, context)
        super(object, context)
      end

      field :key, String, null: false

      field :count, Integer, null: false

      field :group_by, self, null: false, camelize: true

      def key
        group_result[0]
      end

      def count
        group_result[1][:count]
      end

      def group_by
        group_result[1][:nested]
      end

      class << self
        def aggregate(name, *fields, **options, &block)
          aggregate_type = aggregate_type(name)

          field = aggregate_field name, aggregate_type, null: false, **options, &block
          aggregate_type.add_fields(field.own_attributes)

          define_method name do
            group_result[1][name]
          end
        end

        def aggregate_field(*args, **kwargs, &block)
          field_defn = AggregateField.from_options(*args, owner: self, **kwargs, &block)
          add_field(field_defn)
          field_defn
        end

        def own_aggregate_types
          @own_aggregate_types ||= {}
        end

        private

        def aggregate_type(name)
          name = "#{name}AggregateType".upcase_first
          own_aggregate_types[name] ||= Class.new(GraphQL::Groups::AggregateType) do
            graphql_name name
          end
        end
      end
    end
  end
end
