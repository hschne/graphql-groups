# frozen_string_literal: true

module GraphQL
  module Groups
    module Schema
      class AggregateField < GraphQL::Schema::Field
        attr_reader :own_attributes, :query_method

        def initialize(query_method:, **kwargs, &definition_block)
          @query_method = query_method
          super(**kwargs, &definition_block)
        end

        def attribute(attribute)
          @own_attributes ||= []
          @own_attributes += Array.wrap(attribute)
        end
      end
    end
  end
end
