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
              field attribute, Float, null: false

              define_method attribute do
                object[attribute]
              end
            end
          end
        end
      end
    end
  end
end
