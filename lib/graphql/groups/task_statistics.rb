# frozen_string_literal: true

# A query class used for fetching statistics for a collection of tasks. This is used by the GraphQL statistics query
class TaskStatistics
  # Collect receives an active record relation for tasks as well as a has that represents the statistics to collect.
  # It returns a hash that can be consumed by GraphQL to provide a response. One of the main issues here is that
  # GraphQL can construct arbitrary nested queries (e.g. grouping by section, created_at and updated_at).
  def collect(tasks, query)
    # Collecting the required data is a three step process.
    #
    # First, we construct all grouping queries that we will have to run in order to fulfill the query. If the query
    # requires task count per section, as well as task count per section and creation day two group queries are created.
    #
    # Second, the queries are executed.
    #
    # Third, the results of all the queries are merged in a result set that can be consumed by GraphQL.
    queries = build_key_queries(query, tasks)
    results = execute_queries(queries)

    transformed = transform_results(results)
    transformed
  end

  private

  def build_key_queries(groupings, base_query)
    # We construct a hash of queries where the keys are the groups for which statistics need to be collected
    # and the values grouping queries to execute later. Because there can be nested groups we need to construct
    # the queries recursively.
    keys    = get_keys(groupings)
    queries = keys.each_with_object({}) do |key, object|
      object[key] = Array.wrap(key).inject(base_query) { |query, current_key| get_grouping(current_key, query) }
    end
    queries
  end

  def execute_queries(queries)
    queries.each_with_object({}) do |(key, value), object|
      object[key] = value.size
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
    result = results.each_with_object({}) { |(key, value), object| object.deep_merge!(transform_result(key, value)) }
    result
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
    keys = query.keys.select { |key| query[key][:aggregate] }
    query.select { |_, value| value[:nested] }
      .each_with_object(keys) do |(key, value), object|
      get_keys(value[:nested]).each do |item|
        object << (Array.wrap(key) << item)
      end
    end
    keys
  end

  def get_grouping(key, base_query)
    case key
    when :section_id
      base_query.group(:section_id)
    when :created_at
      # TODO: Use CONVERT_TZ to use correct timezone
      base_query.group("DATE_FORMAT(FROM_UNIXTIME(FLOOR(tasks.created_at / 1000)), '%Y-%m-%d')")
    end
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
    transformed_result = result.each_with_object({}) do |(keys, value), object|
      key         = Array.wrap(key)
      keys        = Array.wrap(keys)
      nested      = [:nested] * (key.length - 1)
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
    transformed_result
  end
end
