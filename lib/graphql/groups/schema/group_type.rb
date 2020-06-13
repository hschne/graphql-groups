# frozen_string_literal: true

require 'graphql'


module GraphQL
  module Groups
    module Schema
      class GroupType < GraphQL::Schema::Object
        alias group object

        def initialize(object, context)
          super(object, context)
        end

        field_class(GroupField)

        class << self
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

          def result_type(&block)
            @own_result_type = instance_eval(&block)
          end

          def scope(&block)
            @own_scope = block
          end

          private

          def own_result_type
            name = "#{self.name.gsub(/Type$/, '')}ResultType"

            @own_result_type ||= Class.new(GraphQL::Groups::Schema::GroupResultType) do
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
end
