# frozen_string_literal: true

class QueryBuilderContext
  attr_reader :grouping
  attr_reader :current_proc

  def initialize(groupings = [], current_proc = nil)
    @grouping = groupings
    @current_proc = current_proc
  end

  def update(grouping, new_proc)
    new_grouping = @grouping + [grouping]
    combined_proc = combine_procs(@current_proc, new_proc)
    QueryBuilderContext.new(new_grouping, combined_proc)
  end

  def combine_procs(base_proc, new_proc)
    proc { new_proc.call(base_proc.call) }
  end
end
