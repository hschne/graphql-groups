# frozen_string_literal: true

require 'graphql'

module GraphQL
  module Groups
    class GroupType < GraphQL::Schema::Object
      alias group object

      def self.by(name, type, **options, &block)

        field name, [type], null: false, **options, &block

        define_method name do
          group[name]
        end
      end
    end
  end
end
