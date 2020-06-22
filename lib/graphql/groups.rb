# frozen_string_literal: true

require 'graphql/groups/version'


require 'graphql'

require 'graphql/groups/extensions/wrap'

require 'graphql/groups/schema/group_field'
require 'graphql/groups/schema/aggregate_field'
require 'graphql/groups/schema/aggregate_type'

require 'graphql/groups/aggregates'

require 'graphql/groups/schema/group_result_type'
require 'graphql/groups/schema/group_type'

require 'graphql/groups/lookahead_parser'
require 'graphql/groups/type_parser'
require 'graphql/groups/query_executor'
require 'graphql/groups/execution_plan'


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
