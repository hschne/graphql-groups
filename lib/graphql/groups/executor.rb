# frozen_string_literal: true

module GraphQL
  module Groups
    class Executor
      class << self
        def call(base_query, execution_plan)
          execution_plan.each_with_object({}) do |(key, value), object|
            object.merge!(execute(base_query, key, value))
          end
        end

        def execute(scope, key, value)
          group_query = value[:proc].call(scope: scope)
          results = value[:aggregates].each_with_object({}) do |(aggregate_key, aggregate), object|
            if aggregate_key == :count
              object[:count] = aggregate[:proc].call(scope: group_query)
            else
              object[aggregate_key] ||= {}
              aggregate[:attributes].each do |attribute|
                result = aggregate[:proc].call(scope: group_query, attribute: attribute)
                object[aggregate_key][attribute] = result
              end
            end
          end

          return { key => results } unless value[:nested]

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
