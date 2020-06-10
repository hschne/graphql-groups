class GroupField < GraphQL::Schema::Field
  def query(*args, **kwargs, &block)
    @own_query = block
  end

  def own_query
    @own_query ||= proc { |scope| scope.group(name) }
  end
end
