# frozen_string_literal: true
module GraphQL
  module Groups
    module Aggregates
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def aggregate(name, *_, **options, &block)
          aggregate_type = aggregate_type(name)

          field = aggregate_field name, aggregate_type, null: false, **options, &block
          aggregate_type.add_fields(field.own_attributes)

          define_method name do
            group_result[1][name]
          end
        end

        def aggregate_field(*args, **kwargs, &block)
          field_defn = Schema::AggregateField.from_options(*args, owner: self, **kwargs, &block)
          add_field(field_defn)
          field_defn
        end

        def aggregate_type(name)
          name                      = "#{name}AggregateType".upcase_first
          own_aggregate_types[name] ||= Class.new(Schema::AggregateType) do
            graphql_name name
          end
        end

        def own_aggregate_types
          @own_aggregate_types ||= {}
        end
      end
    end
  end
end
