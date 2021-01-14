# frozen_string_literal: true

module GraphQL
  module Groups
    class PendingQuery
      attr_reader :key
      attr_reader :aggregate
      attr_reader :query

      def initialize(key, aggregate, proc)
        @key = Utils.wrap(key)
        @aggregate = Utils.wrap(aggregate)
        @query = proc
      end

      def execute
        result = @query.call
        QueryResult.new(@key, @aggregate, result)
      end
    end
  end
end
