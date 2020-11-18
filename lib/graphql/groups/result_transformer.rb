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
        keys.each_with_index do |key, index|
          object[key] ||= {}
          query_result.result_hash.each do |grouping_result|
            group_result_key = grouping_result[0]
            group_result_value = grouping_result[1]
            object[key][group_result_key] ||= {}
            object[key][group_result_key][query_result.aggregate[0]] = group_result_value
          end
        end
      end

      # def transform_results(results)
      #   # Because group query returns its results in a way that is not usable by GraphQL we need to transform these results
      #   # and merge them into a single dataset.
      #   #
      #   # The result of a group query usually is a hash where they keys are the values of the columns that were grouped
      #   # and the values are the aggregates. What we want is a deep hash where each level contains the statistics for that
      #   # level in regards to the parent level.
      #   #
      #   # It all makes a lot more sense if you look at the GraphQL interface for statistics :)
      #   #
      #   # We accomplish this by transforming each result set to a hash and then merging them into a single one.
      #   results.each_with_object({}) { |(key, value), object| object.deep_merge!(transform_result(key, value)) }
      # end

      # def transform_result(key, result)
      #   transformed = result.each_with_object({}) do |(aggregate_key, aggregate_value), object|
      #     if aggregate_value.values.any? { |x| x.is_a?(Hash) }
      #       aggregate_value.each do |attribute, value|
      #         object.deep_merge!(transform_attribute(key, aggregate_key, attribute, value))
      #       end
      #     else
      #       object.deep_merge!(transform_aggregate(key, aggregate_key, aggregate_value))
      #     end
      #   end
      #
      #   transformed.presence || { key => [] }
      # end
      #
      # # TODO: Merge transform aggregate and transform attribute
      # def transform_aggregate(key, aggregate, result)
      #   result.each_with_object({}) do |(keys, value), object|
      #     with_zipped = build_keys(key, keys)
      #     with_zipped.append(aggregate)
      #     hash = with_zipped.reverse.inject(value) { |a, n| { n => a } }
      #     object.deep_merge!(hash)
      #   end
      # end
      #
      # def transform_attribute(key, aggregate, attribute, result)
      #   result.each_with_object({}) do |(keys, value), object|
      #     with_zipped = build_keys(key, keys)
      #     with_zipped.append(aggregate)
      #     with_zipped.append(attribute)
      #     hash = with_zipped.reverse.inject(value) { |a, n| { n => a } }
      #     object.deep_merge!(hash)
      #   end
      # end
      #
      # def build_keys(key, keys)
      #   key = wrap(key)
      #   keys = keys ? wrap(keys) : [nil]
      #   nested = [:nested] * (key.length - 1)
      #
      #   with_zipped = key.zip(keys).zip(nested).flatten!
      #   with_zipped.first(with_zipped.size - 1)
      # end
    end
  end
end
