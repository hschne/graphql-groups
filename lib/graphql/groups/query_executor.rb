# frozen_string_literal: true

module GraphQL
  module Groups
    class QueryExecutor
      def run(execution_plan)
        @execution_plan = execution_plan
        results         = execute_queries(execution_plan)

        transform_results(results)
      end

      private

      def execute_queries(execution_plan)
        execution_plan.queries.each_with_object({}) do |(key, value), object|
          object[key] = instance_eval(value)
        end
      end

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
        # We use the composite key of the query that was run (e.g. [:section_id, :created_at]) as key. The result is the
        # result set of the corresponding query. We transform this into a nested hash of the form:
        #
        #  {
        #    section_id: {
        #      <section_id> => {
        #        nested: {
        #          created_at: {
        #            '2020-01-01': {
        #               count: <value>
        #            }
        #          }
        #        }
        #      }
        #    }
        #  }
        result.each_with_object({}) do |(keys, value), object|
          key    = Array.wrap(key)
          keys   = Array.wrap(keys)
          nested = [:nested] * (key.length - 1)
          # We construct an array that will later be turned into the hash. To created the structure we want we zip the key
          # (e.g. [:section_id, :created_at]) with the result set key (e.g. [1, '2020-01-01']) and then zip that with [:nested]
          # key resulting in e.g. [:section_id, 1, :nested, :created_at, '2020-01-01'].
          #
          # The innermost hash contains the result value of a result row. Merging multiple such hashes together we get a hash
          # representation of the result of the entire grouping query.
          #
          # See https://stackoverflow.com/a/5095149/2553104
          with_zipped = key.zip(keys).zip(nested).flatten!.compact
          hash        = with_zipped.reverse.inject(count: value) { |a, n| { n => a } }
          object.deep_merge!(hash)
        end
      end
    end
  end
end
