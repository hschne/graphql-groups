# frozen_string_literal: true

require 'graphql/groups/version'
require 'graphql/groups/query_executor'
require 'graphql/groups/execution_plan'
require 'graphql/groups/lookahead_parser'

require 'graphql/groups/group_type'
require 'graphql/groups/aggregate_field'
require 'graphql/groups/aggregate_type'

require 'graphql/groups/extensions/wrap'

module GraphQL
  module Groups
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      KEYS = %i[type default description required camelize].freeze

      def group(name, type, **options)
        field name, type, extras: [:lookahead], null: false, **options

        define_method name do |lookahead: nil|
          execution_plan = ExecutionPlan.build(type, lookahead)
          GraphQL::Groups::QueryExecutor.new.run(execution_plan)
        end
      end
    end
  end
end
