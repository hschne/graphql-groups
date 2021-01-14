# frozen_string_literal: true

module GraphQL
  module Groups
    module HasGroups
      def self.included(base)
        base.extend(ClassMethods)
      end

      attr_reader :scope

      def initialize(object, context)
        super(object, context)
        @scope = instance_eval(&self.class.class_scope)
      end

      module ClassMethods
        attr_reader :class_scope

        def by(name, **options, &block)
          query_method = options[:query_method] || name
          resolver_method = "resolve_#{query_method}".to_sym
          group_field name, [own_result_type],
                      query_method: query_method,
                      null: true,
                      resolver_method: resolver_method,

                      **options, &block

          define_method query_method do |**kwargs|
            kwargs[:scope].group(name)
          end

          define_method resolver_method do |**_|
            group[name]
          end
        end

        def group_field(*args, **kwargs, &block)
          field_defn = field_class.from_options(*args, owner: self, **kwargs, &block)
          add_field(field_defn)
          field_defn
        end

        def result_type(&block)
          @own_result_type = instance_eval(&block)
        end

        def scope(&block)
          @class_scope = block
        end

        private

        def own_result_type
          type = find_result_type
          own_group_type = self

          registry = GraphQL::Groups::GroupTypeRegistry.instance
          # To avoid name conflicts check if a result type has already been registered, and if not create a new one
          registry.get(type) || registry.register(type, Class.new(type) do
            graphql_name type.name.demodulize

            field :group_by, own_group_type, null: false, camelize: true

            def group_by
              group_result[1][:group_by]
            end
          end)
        end

        def own_field_type
          type = "#{name}Field"
          base_field_type = field_class
          registry = GraphQL::Groups::GroupTypeRegistry.instance
          registry.get(type) || registry.register(type, Class.new(base_field_type) do
            attr_reader :query_method

            def initialize(query_method:, **options, &definition_block)
              @query_method = query_method
              super(**options.except(:query_method), &definition_block)
            end
          end)
        end

        def find_result_type
          return @own_result_type if @own_result_type

          return GraphQL::Groups::Schema::GroupResultType unless name

          "#{name.gsub(/Type$/, '')}ResultType".safe_constantize || GraphQL::Groups::Schema::GroupResultType
        end
      end
    end
  end
end
