# frozen_string_literal: true

class QueryResult
  attr_reader :key
  attr_reader :aggregate
  attr_reader :result_hash

  def initialize(key, aggregate, result)
    @key = wrap(key)
    @aggregate = wrap(aggregate)
    @result_hash = result
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
