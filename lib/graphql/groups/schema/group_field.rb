# frozen_string_literal: true

module GraphQL
  module Groups
    module Schema
      class GroupField < GraphQL::Schema::Field
        attr_reader :query_method

        def initialize(query_method:, **options, &definition_block)
          # TODO: Make sure that users can access the context in custom query methods
          @query_method = query_method
          super(**options, &definition_block)
        end
      end
    end
  end
end
