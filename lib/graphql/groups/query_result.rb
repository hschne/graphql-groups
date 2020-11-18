class QueryResult
  attr_reader :key
  attr_reader :aggregate
  attr_reader :result_hash

  def initialize(key, aggregate, result)
    @key = key
    @aggregate = aggregate
    @result_hash = result
  end
end
