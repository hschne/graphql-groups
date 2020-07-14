# frozen_string_literal: true

require 'graphql/groups/version'

require 'graphql'
require 'graphql/groups/extensions/wrap'

require 'graphql/groups/schema/group_field'
require 'graphql/groups/schema/aggregate_field'
require 'graphql/groups/schema/aggregate_type'

require 'graphql/groups/has_aggregates'
require 'graphql/groups/has_groups'

require 'graphql/groups/schema/group_result_type'
require 'graphql/groups/schema/group_type'

require 'graphql/groups/lookahead_parser'
require 'graphql/groups/result_transformer'
require 'graphql/groups/executor'


module GraphQL
  module Groups
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def group(name, type, **options)
        # TODO: Suppress/warn if options are used that cannot be used
        field name, type, extras: [:lookahead], null: false, **options

        define_method name do |lookahead: nil|
          execution_plan = GraphQL::Groups::LookaheadParser.parse(lookahead)
          base_query = nil
          type.instance_eval do
            base_query = instance_eval(&@own_scope)
          end
          results = Executor.call(base_query, execution_plan)
          GraphQL::Groups::ResultTransformer.new.run(results)
        end
      end
    end
  end
end
