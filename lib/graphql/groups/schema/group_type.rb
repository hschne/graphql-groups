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
            query_method = options[:resolve_method] || name
            resolver_method = "resolve_#{query_method}".to_sym
            group_field name, [own_result_type],
                        null: false,
                        resolver_method: resolver_method,
                        query_method: query_method,
                        **options, &block

            define_method query_method do |**kwargs|
              kwargs[:scope].group(name)
            end

            define_method resolver_method do |**kwargs|
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

            type = name.safe_constantize || GraphQL::Groups::Schema::GroupResultType
            own_group_type = self

            @classes ||= {}
            @classes[type] ||= Class.new(type) do
              graphql_name name

              field :group_by, own_group_type, null: false, camelize: true

              def group_by
                group_result[1][:nested]
              end
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
