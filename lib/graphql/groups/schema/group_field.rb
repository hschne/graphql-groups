# frozen_string_literal: true

module GraphQL
  module Groups
    module Schema
      class GroupField < GraphQL::Schema::Field

        attr_reader :query_method

        def initialize(query_method:, **options, &definition_block)
          @query_method = query_method
          super(**options, &definition_block)
        end

        def own_query
          name       = self.name.to_sym
          @own_query ||= proc { |scope| scope.group(name) }
        end
      end
    end
  end
end
