require 'spec_helper'

module GraphQL
  module Groups
    module Schema
      RSpec.describe HasGroups do
        before do
          GraphQL::Groups::GroupTypeRegistry.instance.clear
        end

        it 'defines a method with query method parameter' do
          item = Class.new(GraphQL::Schema::Object) do
            graphql_name 'name'
            include HasGroups
            field_class(own_field_type)

            by(:name, query_method: :test)
          end

          expect(item.instance_methods).to include(:test)
        end

        it 'defines a default query param method' do
          item = Class.new(GraphQL::Schema::Object) do
            graphql_name 'name'
            include HasGroups
            field_class(own_field_type)

            by(:name)
          end

          expect(item.instance_methods).to include(:name)
        end

        it 'defines a resolve method' do
          item = Class.new(GraphQL::Schema::Object) do
            graphql_name 'name'
            include HasGroups
            field_class(own_field_type)

            by(:name)
          end

          expect(item.instance_methods).to include(:resolve_name)
        end

        it 'defines a group field' do
          item = Class.new(GraphQL::Schema::Object) do
            graphql_name 'name'
            include HasGroups
            field_class(own_field_type)

            by(:name)
          end

          expect(item.fields['name']).not_to be_nil
        end

        it 'uses user field class' do
          field_class = Class.new(GraphQL::Schema::Field) do
            def self.name
              'FieldClass'
            end
          end

          base_object = Class.new(GraphQL::Schema::Object) do
            field_class field_class
          end

          item = Class.new(base_object) do
            graphql_name 'name'
            include HasGroups
            field_class(own_field_type)

            by(:name)
          end

          expect(item.fields['name']).to be_a(field_class)
        end

        context 'with no group result type' do
          it 'uses the field default result type' do
            item = Class.new(GraphQL::Schema::Object) do
              graphql_name 'name'
              include HasGroups
              field_class(own_field_type)

              by(:name)
            end

            field_type = item.fields['name'].type.of_type.of_type.of_type.graphql_name
            expect(field_type).to eq(GroupResultType.name.demodulize)
          end
        end

        context 'with specific result type' do
          it 'defines a field default result type' do
            custom_result_type = Class.new(GraphQL::Schema::Object) { graphql_name 'result_type' }
            Object.const_set 'CustomResultType', custom_result_type
            item = Class.new(GraphQL::Schema::Object) do
              graphql_name 'name'
              include HasGroups
              field_class(own_field_type)

              result_type { custom_result_type }

              by(:name)
            end

            field_type = item.fields['name'].type.of_type.of_type.of_type.graphql_name
            expect(field_type).to eq('CustomResultType')
          end
        end

      end
    end
  end
end

