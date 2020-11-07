# frozen_string_literal: true

module GraphQL
  module Groups
    class LookaheadParser
      def self.parse(base_selection)
        LookaheadParser.new.group_selections(base_selection)
      end

      private

      def group_selections(root)
        selections = root.selections
        group_selections = selections.select { |selection| selection.field.is_a?(GraphQL::Groups::Schema::GroupField) }
        top_level_queries =  group_selections.each_with_object([]) do |selection, object|
          own_query = get_field_proc(selection.field, selection.arguments)
          object << create_pending_queries(own_query, selection)
        end
        nested_queries = group_selections
          .filter { |selection| selection.selects?(:group_by) }
          .each_with_object([]) do |selection|
          object << group_selections(selection.selection(:group_by))
        end
        top_level_queries + nested_queries
      end

      def get_field_proc(field, arguments)
        # TODO: Use authorized instead of using send to circument protection
        proc { |**kwargs| field.owner.send(:new, {}, nil).public_send(field.query_method, **arguments, **kwargs) }
      end

      def create_pending_queries(base_query, base_selection)
        aggregate_selections = base_selection.selections.select do |selection|
          selection.field.is_a?(GraphQL::Groups::Schema::AggregateField)
        end
        create_count_queries(aggregate_selections, base_query, base_selection) +
          create_aggregate_queries(aggregate_selections, base_query, base_selection)
      end

      def get_aggregate_proc(field, arguments)
        # TODO: Use authorized instead of using send to circument protection
        proc { |**kwargs| field.owner.send(:new, {}, nil).send(field.query_method, **kwargs, **arguments) }
      end

      def create_count_queries(aggregate_selections, base_query, base_selection)
        aggregate_selections
          .select { |selection| selection.name == :count }
          .each_with_object([]) do |selection, pending_queries|
          field = selection.field
          proc = proc { |**kwargs| field.owner.send(:new, {}, nil).public_send(field.query_method, **kwargs) }
          combined_query = proc { proc.call(scope: base_query) }
          pending_queries << PendingQuery.new(base_selection.name, selection.name, combined_query)
        end
      end

      def create_aggregate_queries(aggregate_selections, base_query, base_selection)
        aggregate_selections
          .select { |selection| selection.field.own_attributes.present? }
          .each_with_object([]) do |selection, object|
          field.own_attributes.each do |attribute|
            field = selection.field
            proc = get_aggregate_proc(field, selection.arguments)
            combined_query = proc { proc.call(scope: base_query, attribute: attribute) }
            object << PendingQuery.new(base_selection.name, [selection.name, attribute], combined_query)
          end
        end
      end
    end
  end
end
