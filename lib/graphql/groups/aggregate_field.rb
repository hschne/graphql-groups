class AggregateField < GraphQL::Schema::Field
  def with(*args, **kwargs, &block)
    @own_query = block
  end

  def own_aggregate
    name = self.name.to_sym
    @own_aggregate ||= proc { |scope| scope.size }
  end
end
