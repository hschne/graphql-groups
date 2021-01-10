# frozen_string_literal: true

class QueryBuilderContext
  attr_reader :grouping
  attr_reader :proc

  def initialize(groupings = [], current_proc = nil)
    @grouping = groupings
    @proc = current_proc
  end

  def update(grouping, proc)
    new_grouping = @grouping + [grouping]
    combined_proc = combine_procs(@proc, proc)
    QueryBuilderContext.new(new_grouping, combined_proc)
  end

  def combine_procs(base_proc, new_proc)
    return new_proc unless base_proc

    proc do |scope|
      base = base_proc.call(scope: scope)
      new_proc.call(scope: base)
    end
  end
end
