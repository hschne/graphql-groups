# frozen_string_literal: true

require 'graphql/groups/version'

require 'graphql'

require 'graphql/groups/group_type_registry'
require 'graphql/groups/schema/group_field'
require 'graphql/groups/schema/aggregate_field'
require 'graphql/groups/schema/aggregate_type'

require 'graphql/groups/has_aggregates'
require 'graphql/groups/has_groups'

require 'graphql/groups/schema/group_result_type'
require 'graphql/groups/schema/group_type'

require 'graphql/groups/query_result'
require 'graphql/groups/pending_query'
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
        field name, type, extras: [:lookahead], null: false, **options

        define_method name do |lookahead: nil|
          pending_queries = LookaheadParser.parse(lookahead, context)
          base_query = type.authorized_new(object, context).scope
          query_resuls = Executor.call(base_query, pending_queries)
          GraphQL::Groups::ResultTransformer.new.run(query_resuls)
        end
      end
    end
  end
end
