# frozen_string_literal: true

module GraphQL
  module Groups
    class ExecutionPlan
      attr_reader :queries

      def initialize(queries)
        @queries = queries
      end

      def fetch(key)
        @queries[key]
      end

      class << self
        def build(group_type, lookahead)
          base_query = nil
          group_type.instance_eval do
            base_query = instance_eval(&@own_scope)
          end
          requested_data = GraphQL::Groups::LookaheadParser.parse(lookahead)
          requested_data.each_with_object({}) do |(key, value), object|
            object.merge!(resolve(base_query, [], key, value))
          end
        end

        def resolve(scope, base_key, key, value)
          group_query = instance_exec(scope, &value[:proc])
          results = value[:aggregates].each_with_object({}) do |(aggregate_key, aggregate), object|
            if aggregate_key == :count
              object[:count] = instance_exec(group_query, aggregate, &aggregate[:proc])
            else
              object[aggregate_key] ||= {}
              aggregate[:attributes].each do |attribute|
                result = instance_exec(group_query, attribute, &aggregate[:proc])
                object[aggregate_key][attribute] = result
              end
            end
          end
          new_key = (base_key << key)
          result = { new_key => results }
          return result unless value[:nested]

          value[:nested].each do |key, value|
            result.merge!(resolve(group_query, new_key, key, value))
          end
        end

        def build_key_queries(base_query, requested_data)
          # We construct a hash of queries where the keys are the groups for which statistics need to be collected
          # and the values grouping queries to execute later. Because there can be nested groups we need to construct
          # the queries recursively.
          keys = get_keys(requested_data)
          keys.each_with_object({}) do |key, object|
            object[key] = Array.wrap(key).inject(base_query) { |query, current_key| instance_exec(query, &queries[current_key]) }
          end
        end

        def get_keys(query)
          # We construct a list of keys that we need to run group queries for. We also reuse these keys later to merge the
          # query results into one big result. We only need to collect keys for groups for which we will have to collect
          # statistics, i.e. if the aggregate key exists in the query.
          #
          # If there are nested queries with aggregates we recursively collect those as well and merge them into a single list
          #
          # === Example ===
          #
          #   [
          #     [:section_id],
          #     [:section_id, :created_at],
          #     [:section_id, :updated_at]
          #   ]
          keys = query.keys.select { |key| query[key][:aggregates] }
          query.select { |_, value| value[:nested] }
            .each_with_object(keys) do |(key, value), object|
            get_keys(value[:nested]).each do |item|
              object << (Array.wrap(key) << item)
            end
          end
          keys
        end
      end
    end
  end
end
