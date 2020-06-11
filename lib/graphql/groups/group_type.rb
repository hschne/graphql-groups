# frozen_string_literal: true

require 'graphql'

require 'graphql/groups/group_field'
require 'graphql/groups/group_result_type'

module GraphQL
  module Groups
    class GroupType < GraphQL::Schema::Object
      alias group object

      def initialize(object, context)
        super(object, context)
      end

      field_class(GroupField)

      class << self
        attr_reader :config

        def by(name, **options, &block)
          group_field name, [own_result_type], null: false, **options, &block

          define_method name do
            group[name]
          end
        end

        def group_field(*args, **kwargs, &block)
          field_defn = GroupField.from_options(*args, owner: self, **kwargs, &block)
          add_field(field_defn)
          field_defn
        end

        def result_type(result_type)
          @own_result_type = result_type
        end

        def scope(&block)
          @own_scope = block
        end

        private

        def own_result_type
          name = "#{self.name.gsub(/Type$/, '')}ResultType"

          @result_type ||= Class.new(GraphQL::Groups::GroupResultType) do
            graphql_name name
          end
        end

        def own_scope
          @own_scope ||= nil
        end
      end
    end
  end
end
