# frozen_string_literal: true

class AggregateField < GraphQL::Schema::Field
  def attribute(attribute)
    own_attributes
    @own_attributes += Array.wrap(attribute)
  end

  def with(&block)
    @own_query = block
  end

  def own_attributes
    @own_attributes ||= []
  end
end
