# frozen_string_literal: true

class QueryBuilderContext
  attr_reader :grouping
  attr_reader :proc

  def initialize(groupings = [], current_proc = nil)
    @grouping = groupings
    @proc = current_proc
  end

  def update(grouping, proc)
    @grouping.append(grouping)
    @proc = combine_procs(@proc, proc)
    QueryBuilderContext.new(@grouping, @proc)
  end

  def combine_procs(base_proc, new_proc)
    return new_proc unless base_proc

    proc do |scope|
      base = @proc.call(scope: scope)
      new_proc.call(scope: base)
    end
  end
end
