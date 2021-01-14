# frozen_string_literal: true

module GraphQL
  module Groups
    class QueryBuilder
      def self.parse(lookahead, object, context)
        QueryBuilder.new(lookahead, object, context).group_selections
      end

      def initialize(lookahead, object, context)
        @lookahead = lookahead
        @context = context
        type = @lookahead.field.type.of_type
        @base_query = proc { type.authorized_new(object, context).scope }
        super()
      end

      def group_selections(lookahead = @lookahead, current_context = QueryBuilderContext.new([], @base_query))
        selections = lookahead.selections
        group_field_type = lookahead.field.type.of_type.field_class
        group_selections = selections.select { |selection| selection.field.is_a?(group_field_type) }
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
        count_queries = count_queries(aggregate_selections, context)
        aggregate_queries = aggregate_queries(aggregate_selections, context)
        (count_queries + aggregate_queries)
      end

      def count_queries(aggregate_selections, context)
        aggregate_selections
          .select { |selection| selection.name == :count }
          .map do |selection|
          field = selection.field
          count_proc = proc { |scope| field.owner.send(:new, {}, nil).public_send(field.query_method, scope: scope) }
          combined = combine_procs(context.current_proc, count_proc)
          PendingQuery.new(context.grouping, selection.name, combined)
        end
      end

      def aggregate_queries(aggregate_selections, context)
        aggregate_selections
          .select { |selection| selection.field.own_attributes.present? }
          .map { |selection| attribute_queries(context, selection) }
          .flatten
      end

      def attribute_queries(context, selection)
        selection.field
          .own_attributes
          .select { |attribute| selection.selections.map(&:name).include?(attribute) }
          .map do |attribute|
          aggregate_proc = proc_from_attribute(selection.field, attribute, selection.arguments)
          combined = combine_procs(context.current_proc, aggregate_proc)
          PendingQuery.new(context.grouping, [selection.name, attribute], combined)
        end
      end

      def combine_procs(base_proc, new_proc)
        proc { new_proc.call(base_proc.call) }
      end

      def proc_from_selection(field, arguments)
        proc { |scope| field.owner.authorized_new(nil, @context).public_send(field.query_method, scope: scope, **arguments) }
      end

      def proc_from_attribute(field, attribute, arguments)
        proc do |scope|
          field.owner.authorized_new(nil, @context)
            .public_send(field.query_method,
                         scope: scope,
                         attribute: attribute, **arguments)
        end
      end
    end
  end
end
