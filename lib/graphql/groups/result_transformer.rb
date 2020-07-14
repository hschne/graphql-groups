# frozen_string_literal: true

module GraphQL
  module Groups
    class ResultTransformer
      def run(results)
        transform_results(results)
      end

      private

      def transform_results(results)
        # Because group query returns its results in a way that is not usable by GraphQL we need to transform these results
        # and merge them into a single dataset.
        #
        # The result of a group query usually is a hash where they keys are the values of the columns that were grouped
        # and the values are the aggregates. What we want is a deep hash where each level contains the statistics for that
        # level in regards to the parent level.
        #
        # It all makes a lot more sense if you look at the GraphQL interface for statistics :)
        #
        # We accomplish this by transforming each result set to a hash and then merging them into a single one.
        results.each_with_object({}) { |(key, value), object| object.deep_merge!(transform_result(key, value)) }
      end

      def transform_result(key, result)
        result.each_with_object({}) do |(aggregate_key, value), object|
          if value.values.any? { |x| x.is_a?(Hash) }
            value.each { |attribute, value| object.deep_merge!(transform_attribute(key, aggregate_key, attribute, value)) }
          else
            object.deep_merge!(transform_aggregate(key, aggregate_key, value))
          end
        end
      end

      # TODO: Merge transform aggregate and transform attribute
      def transform_aggregate(key, aggregate, result)
        result.each_with_object({}) do |(keys, value), object|
          key = Array.wrap(key)
          keys = keys ? Array.wrap(keys).map { |x| x || 'null' } : ['null']
          nested = [:nested] * (key.length - 1)

          # See https://stackoverflow.com/a/5095149/2553104
          with_zipped = key.zip(keys).zip(nested).flatten!.compact
          with_zipped.append(aggregate)
          hash = with_zipped.reverse.inject(value) { |a, n| { n => a } }
          object.deep_merge!(hash)
        end
      end

      def transform_attribute(key, aggregate, attribute, result)
        result.each_with_object({}) do |(keys, value), object|
          key = Array.wrap(key)
          keys = keys ? Array.wrap(keys).map { |x| x || 'null' } : ['null']
          nested = [:nested] * (key.length - 1)

          with_zipped = key.zip(keys).zip(nested).flatten!.compact
          with_zipped.append(aggregate)
          with_zipped.append(attribute)
          hash = with_zipped.reverse.inject(value) { |a, n| { n => a } }
          object.deep_merge!(hash)
        end
      end
    end
  end
end
