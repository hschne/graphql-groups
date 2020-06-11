# frozen_string_literal: true

require 'graphql/groups/version'
require 'graphql/groups/query_executor'
require 'graphql/groups/lookahead_parser'

require 'graphql/groups/group_type'

module GraphQL
  module Groups
    def self.included(base)
      base.extend ClassMethods
      base.instance_eval do
        @config = {
          defaults: {},
          options:  {}
        }
      end
    end

    module ClassMethods
      KEYS = %i[type default description required camelize].freeze

      def group(name, type, **options)
        field name, type, extras: [:lookahead], null: false, **options

        define_method name do |lookahead: nil|
          query   = GraphQL::Groups::LookaheadParser.parse(lookahead)
          scope   = nil
          queries = nil
          type.instance_eval do
            scope   = instance_eval(&@own_scope)
            queries = own_fields
                        .delete_if { |_, value| !value.is_a?(GroupField) }
                        .transform_values!(&:own_query)
                        .symbolize_keys
          end
          GraphQL::Groups::QueryExecutor.new.run(scope, query, queries)
        end
      end
    end
  end
end
