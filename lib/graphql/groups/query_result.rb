# frozen_string_literal: true

module GraphQL
  module Groups
    class QueryResult
      attr_reader :key
      attr_reader :aggregate
      attr_reader :result_hash

      def initialize(key, aggregate, result)
        @key = Utils.wrap(key)
        @aggregate = Utils.wrap(aggregate)
        @result_hash = result
      end
    end
  end
end
