# frozen_string_literal: true

module GraphQL
  module Groups
    class ResultTransformer
      def run(query_results)
        # Sort by key length so that deeper nested queries come later
        query_results
          .sort_by { |query_result| query_result.key.length }
          .each_with_object({}) do |query_result, object|
          transform_result(query_result, object)
        end
      end

      private

      def transform_result(query_result, object)
        keys = query_result.key
        query_result.result_hash.each do |grouping_result|
          group_result_keys = grouping_result[0]
          group_result_value = grouping_result[1]
          inner_hash = create_nested_result(keys, group_result_keys, object)
          if query_result.aggregate.length == 1
            inner_hash[query_result.aggregate[0]] = group_result_value
          else
            aggregate_type = query_result.aggregate[0]
            aggregate_attribute = query_result.aggregate[1]
            inner_hash[aggregate_type] ||= {}
            inner_hash[aggregate_type][aggregate_attribute] ||= group_result_value
          end
        end
      end

      def create_nested_result(keys, group_result_keys, object)
        head_key, *rest_keys = keys
        head_group_key, *rest_group_keys = group_result_keys
        object[head_key] ||= {}
        object[head_key][head_group_key] ||= {}
        inner_hash = object[head_key][head_group_key]
        return inner_hash if rest_keys.empty?

        inner_hash[:group_by] ||= {}
        create_nested_result(rest_keys, rest_group_keys, inner_hash[:group_by])
      end
    end
  end
end
