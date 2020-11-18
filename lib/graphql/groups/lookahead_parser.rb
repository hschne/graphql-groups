# frozen_string_literal: true

module GraphQL
  module Groups
    class LookaheadParser
      def self.parse(lookahead, context)
        LookaheadParser.new(lookahead, context).group_selections
      end

      def initialize(lookahead, context)
        @lookahead = lookahead
        @context = context
        super()
      end

      def group_selections(lookahead = @lookahead)
        selections = lookahead.selections
        group_selections = selections.select { |selection| selection.field.is_a?(GraphQL::Groups::Schema::GroupField) }
        top_level_queries = group_selections.each_with_object([]) do |selection, object|
          grouping_query = get_field_proc(selection.field, selection.arguments)
          object << create_pending_queries(grouping_query, selection)
        end
        nested_queries = group_selections
                           .filter { |selection| selection.selects?(:group_by) }
                           .each_with_object([]) do |selection, object|
          object << group_selections(selection.selection(:group_by))
        end
        (top_level_queries + nested_queries).flatten
      end

      private

      def create_pending_queries(base_query, base_selection)
        aggregate_selections = base_selection.selections.select do |selection|
          selection.field.is_a?(GraphQL::Groups::Schema::AggregateField)
        end
        create_count_queries(aggregate_selections, base_query, base_selection) +
          create_aggregate_queries(aggregate_selections, base_query, base_selection)
      end

      def create_count_queries(aggregate_selections, grouping_query, base_selection)
        aggregate_selections
          .select { |selection| selection.name == :count }
          .each_with_object([]) do |selection, pending_queries|
          field = selection.field
          proc = proc { |**kwargs| field.owner.send(:new, {}, nil).public_send(field.query_method, **kwargs) }
          combined_proc = proc do |scope|
            base = grouping_query.call(scope: scope)
            proc.call(scope: base)
          end
          pending_queries << PendingQuery.new(base_selection.name, selection.name, combined_proc)
        end
      end

      def create_aggregate_queries(aggregate_selections, base_query, base_selection)
        aggregate_selections
          .select { |selection| selection.field.own_attributes.present? }
          .each_with_object([]) do |selection, object|
          field.own_attributes.each do |attribute|
            field = selection.field
            proc = get_aggregate_proc(field, selection.arguments)
            combined_proc = proc do |scope|
              base = grouping_query.call(scope: scope)
              proc.call(scope: base, attribute: attribute)
            end
            object << PendingQuery.new(base_selection.name, [selection.name, attribute], combined_proc)
          end
        end
      end

      def get_field_proc(field, arguments)
        proc { |**kwargs| field.owner.authorized_new(nil, @context).public_send(field.query_method, **arguments, **kwargs) }
      end

      def get_aggregate_proc(field, arguments)
        proc { |**kwargs| field.owner.authorized_new(nil, @context).public_send(field.query_method, **arguments, **kwargs) }
      end
    end
  end
end
