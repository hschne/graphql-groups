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
require 'graphql/groups/query_builder_context'
require 'graphql/groups/query_builder'
require 'graphql/groups/result_transformer'


module GraphQL
  module Groups
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def group(name, type, **options)
        field name, type, extras: [:lookahead], null: false, **options

        define_method name do |lookahead: nil|
          base_query = type.authorized_new(object, context).scope
          pending_queries = QueryBuilder.parse(lookahead, context, base_query)
          query_results = pending_queries.map { |pending_query| pending_query.execute }
          GraphQL::Groups::ResultTransformer.new.run(query_results)
        end
      end
    end
  end
end
