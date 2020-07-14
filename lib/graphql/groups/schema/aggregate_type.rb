# frozen_string_literal: true

require 'graphql'

module GraphQL
  module Groups
    module Schema
      class AggregateType < GraphQL::Schema::Object
        alias aggregate object

        class << self
          def add_fields(fields)
            fields.each do |attribute|
              resolve_method = "resolve_#{attribute}".to_sym
              field attribute, Float, null: false, resolver_method: resolve_method

              define_method resolve_method do
                object[attribute]
              end
            end
          end
        end
      end
    end
  end
end
