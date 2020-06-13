# frozen_string_literal: true

module GraphQL
  module Groups
    module Schema
      class AggregateField < GraphQL::Schema::Field
        attr_reader :own_attributes, :own_query

        def attribute(attribute)
          @own_attributes ||= []
          @own_attributes += Array.wrap(attribute)
        end

        def with(&block)
          @own_query = block
        end
      end
    end
  end
end
