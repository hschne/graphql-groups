# frozen_string_literal: true

require 'graphql/groups/version'
require 'graphql/groups/query_executor'
require 'graphql/groups/lookahead_parser'

require 'graphql/groups/group_type'
require 'graphql/groups/group_result_type'

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

      def group(name, type, scope:, **options)
        # TODO: Error handling, check if type is GraphQL type etc
        field name, type, extras: [:lookahead], null: false, **options

        define_method name do |lookahead: nil|
          query = GraphQL::Groups::LookaheadParser.parse(lookahead)
          GraphQL::Groups::QueryExecutor.new.run(scope, query)
        end
      end

      def scope(&block)
        config[:scope] = block
      end

      def result(&block)
        config[:result] = block
      end
    end
  end
end
