class QueryResult
  attr_reader :key
  attr_reader :aggregate
  attr_reader :query

  def initialize(key, aggregate, result)
    @key = key
    @aggregate = aggregate
    @result = result
  end
end
