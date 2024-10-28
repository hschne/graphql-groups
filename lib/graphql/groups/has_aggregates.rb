# frozen_string_literal: true

module GraphQL
  module Groups
    module HasAggregates
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def aggregate(name, *_, **options, &block)
          aggregate_type = aggregate_type(name)

          resolve_method = "resolve_#{name}".to_sym
          query_method = options[:query_method] || name
          field = aggregate_field name, aggregate_type,
                                  null: false,
                                  query_method:,
                                  resolver_method: resolve_method,
                                  **options, &block
          aggregate_type.add_fields(field.own_attributes)

          define_method query_method do |scope:, **kwargs|
            scope.public_send(name, **kwargs)
          end

          define_method resolve_method do
            group_result[1][name]
          end
        end

        def aggregate_field(*args, **kwargs, &block)
          field_defn = Schema::AggregateField.from_options(*args, owner: self, **kwargs, &block)
          field_defn.ensure_loaded if Gem::Version.new(GraphQL::VERSION) >= Gem::Version.new('2.3')
          add_field(field_defn)
          field_defn
        end

        private

        def aggregate_type(name)
          name = "#{name}AggregateType".upcase_first
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
