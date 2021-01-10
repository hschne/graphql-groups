# frozen_string_literal: true

module GraphQL
  module Groups
    class QueryBuilder
      def self.parse(lookahead, context)
        QueryBuilder.new(lookahead, context).group_selections
      end

      def initialize(lookahead, context)
        @lookahead = lookahead
        @context = context
        super()
      end

      def group_selections(lookahead = @lookahead, current_context = QueryBuilderContext.new)
        selections = lookahead.selections
        group_selections = selections.select { |selection| selection.field.is_a?(GraphQL::Groups::Schema::GroupField) }
        queries = group_selections.each_with_object([]) do |selection, object|
          field_proc = proc_from_selection(selection.field, selection.arguments)
          context = current_context.update(selection.name, field_proc)
          object << create_pending_queries(selection, context)
        end
        nested_queries = group_selections
                           .filter { |selection| selection.selects?(:group_by) }
                           .each_with_object([]) do |selection, object|
          field_proc = proc_from_selection(selection.field, selection.arguments)
          context = current_context.update(selection.name, field_proc)
          object << group_selections(selection.selection(:group_by), context)
        end
        (queries + nested_queries).flatten
      end

      private

      def create_pending_queries(current_selection, context)
        aggregate_selections = current_selection
                                 .selections
                                 .select { |selection| selection.field.is_a?(GraphQL::Groups::Schema::AggregateField) }
        count_queries = aggregate_selections
                          .select { |selection| selection.name == :count }
                          .map do |selection|
          field = selection.field
          count_proc = proc { |**kwargs| field.owner.send(:new, {}, nil).public_send(field.query_method, **kwargs) }
          combined = combine_procs(context.current_proc, count_proc)
          PendingQuery.new(context.grouping, selection.name, combined)
        end
        aggregate_queries = aggregate_selections
                              .select { |selection| selection.field.own_attributes.present? }
                              .map do |selection|
          selection.field.own_attributes.each do |attribute|
            aggregate_proc = proc_from_selection(selection.field, selection.arguments)
            combined = combine_procs(context.current_proc, aggregate_proc)
            PendingQuery.new(context.grouping, [selection.name, attribute], combined)
          end
        end
        (count_queries + aggregate_queries)
      end

      def combine_procs(base_proc, new_proc)
        proc do |scope|
          base = base_proc.call(scope: scope)
          new_proc.call(scope: base)
        end
      end

      def proc_from_selection(field, arguments)
        proc { |**kwargs| field.owner.authorized_new(nil, @context).public_send(field.query_method, **arguments, **kwargs) }
      end
    end
  end
end
