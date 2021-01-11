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
    return new_proc unless base_proc

    proc do |**kwargs|
      base = base_proc.call(**kwargs)
      kwargs[:scope] = base
      new_proc.call(**kwargs)
    end
  end
end
