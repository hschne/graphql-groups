# frozen_string_literal: true

require 'graphql'

require 'graphql/groups/group_field'

module GraphQL
  module Groups
    class GroupType < GraphQL::Schema::Object
      alias group object

      def initialize(object, context)
        super(object, context)
      end

      field_class(GroupField)

      def self.inherited(base)
        base.instance_variable_set '@config', {}
      end

      class << self
        attr_reader :config

        def by(name, **options, &block)
          group_field name, [result_type], null: false, **options, &block

          define_method name do
            group[name]
          end
        end

        def group_field(*args, **kwargs, &block)
          field_defn = field_class.from_options(*args, owner: self, **kwargs, &block)
          add_field(field_defn)
          field_defn
        end

        def scope(&block)
          @own_scope = block
        end

        def execute(lookahead)
          # TODO: Merge into single nice structure
          query   = GraphQL::Groups::LookaheadParser.parse(lookahead)
          scope   = instance_eval(&@own_scope)
          queries = own_fields
                      .delete_if { |_, value| !value.is_a?(GroupField) }
                      .transform_values!(&:own_query)
                      .symbolize_keys
          GraphQL::Groups::QueryExecutor.new.run(scope, query, queries)
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
