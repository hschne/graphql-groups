# frozen_string_literal: true

class PendingQuery
  attr_reader :key
  attr_reader :aggregate
  attr_reader :query

  def initialize(key, aggregate, proc)
    @key = wrap(key)
    @aggregate = wrap(aggregate)
    @query = proc
  end

  def execute(scope)
    result = if @aggregate.size == 1
               @query.call(scope: scope)
             else
               @query.call(scope: scope, attribute: @aggregate[1])
             end
    QueryResult.new(@key, @aggregate, result)
  end

  private

  def wrap(object)
    if object.nil?
      []
    elsif object.respond_to?(:to_ary)
      object.to_ary || [object]
    else
      [object]
    end
  end
end
