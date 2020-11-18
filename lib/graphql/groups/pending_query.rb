# frozen_string_literal: true

class PendingQuery
  attr_reader :key
  attr_reader :aggregate
  attr_reader :query

  def initialize(key, aggregate, proc)
    @key = key
    @aggregate = aggregate
    @query = proc
  end

  def execute(scope)
    result = if @aggregate == :count
               @query.call(scope)
             else
               @query.call(scope, attribute: @aggregate[1])
             end
    QueryResult.new(@key, @aggregate, result)
  end
end
