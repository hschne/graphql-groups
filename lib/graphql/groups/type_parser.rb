# frozen_string_literal: true

# TODO: REMOVE no longer needed
module GraphQL
  module Groups
    class TypeParser
      attr_reader :base_query, :group_queries

      def initialize(base_query, group_queries, aggregate_queries)
        @base_query = base_query
        @group_queries = group_queries
        @aggregate_queries = aggregate_queries
      end

      class << self
        def parse(base_type)
          base_query = nil
          group_fields = nil
          group_queries = nil
          base_type.instance_eval do
            base_query = instance_eval(&@own_scope)
            group_fields = own_fields.delete_if { |_, value| !value.is_a?(Schema::GroupField) }
            group_queries = group_fields.transform_values(&:own_query).symbolize_keys
          end

          aggregate_fields = []
          aggregate_queries = {}
          group_fields.each do |name, field|
            result_type = field.type.of_type.of_type.of_type
            result_type.instance_eval do
              aggregate_fields = own_fields.delete_if { |_, value| !value.is_a?(Schema::AggregateField) }
              aggregate_queries.merge!(aggregate_fields.transform_values(&:own_query).symbolize_keys)
            end
          end

          TypeParser.new(base_query, group_queries, aggregate_queries)
        end
      end
    end
  end
end
