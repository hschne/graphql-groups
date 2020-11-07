
class PendingQuery
  attr_reader :key
  attr_reader :aggregate
  attr_reader :proc

  def initialize(key, aggregate, proc)
    @key = key
    @aggregate = aggregate
    @proc = proc
  end

  def base=(value)

  end

  def aggregate=(aggregate)

  end

  def execute

  end
end
