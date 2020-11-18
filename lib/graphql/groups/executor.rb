# frozen_string_literal: true

module GraphQL
  module Groups
    class Executor
      class << self
        def call(base_query, pending_queries)
          pending_queries.map { |pending_query| pending_query.execute(base_query) }
        end

        def execute(scope, key, value)
          group_query = value[:query].call(scope: scope)
          results = value[:aggregates].each_with_object({}) do |(aggregate_key, aggregate), object|
            if aggregate_key == :count
              object[:count] = aggregate[:query].call(scope: group_query)
            else
              object[aggregate_key] ||= {}
              aggregate[:attributes].each do |attribute|
                result = aggregate[:query].call(scope: group_query, attribute: attribute)
                object[aggregate_key][attribute] = result
              end
            end
          end

          results = { key => results }
          return results unless value[:nested]

          value[:nested].each do |inner_key, inner_value|
            new_key = (Array.wrap(key) << inner_key)
            inner_result = execute(group_query, inner_key, inner_value)
            results[new_key] = inner_result[inner_key]
          end
          results
        end
      end
    end
  end
end
