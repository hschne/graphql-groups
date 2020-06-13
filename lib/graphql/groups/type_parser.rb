# frozen_string_literal: true
module GraphQL
  module Groups
    class TypeParser
      class << self
        def self.parse(base_type)
          base_query    = nil
          group_queries = nil
          base_type.instance_eval do
            base_query    = instance_eval(&@own_scope)
            group_queries = own_fields
                              .delete_if { |_, value| !value.is_a?(Schema::GroupField) }
                              .transform_values(&:own_query)
                              .symbolize_keys
          end
        end
      end
    end
  end
end
