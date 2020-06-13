# frozen_string_literal: true

module GraphQL
  module Groups
    module Schema
      class GroupField < GraphQL::Schema::Field
        def with(*args, **kwargs, &block)
          @own_query = block
        end

        def own_query
          name       = self.name.to_sym
          @own_query ||= proc { |scope| scope.group(name) }
        end
      end
    end
  end
end
