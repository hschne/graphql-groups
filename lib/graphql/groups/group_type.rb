# frozen_string_literal: true

require 'graphql'

module GraphQL
  module Groups
    class GroupType < GraphQL::Schema::Object
      alias group object

      def initialize(object, context)
        super(object, context)
      end

      def self.inherited(base)
        base.instance_variable_set '@config', {}
      end

      class << self
        attr_reader :config

        def by(name, query: nil, **options, &block)
          field name, [result_type], null: false, **options, &block

          define_method name do
            group[name]
          end
        end

        def scope(&block)
          config[:scope] = block
        end

        def execute(lookahead)
          query = GraphQL::Groups::LookaheadParser.parse(lookahead)
          scope = instance_eval(&config[:scope])
          GraphQL::Groups::QueryExecutor.new.run(scope, query)
        end

        private

        def result_type
          name = "#{self.name}ResultType"

          @result_type ||= Class.new(GraphQL::Schema::Object) do
            graphql_name name

            alias_method :group_result, :object

            field :key, String, null: false

            field :count, Integer, null: false

            field :group_by, self, null: false, camelize: true

            def key
              group_result[0]
            end

            def count
              group_result[1][:count]
            end

            def group_by
              group_result[1][:nested]
            end
          end
        end
      end
    end
  end
end
