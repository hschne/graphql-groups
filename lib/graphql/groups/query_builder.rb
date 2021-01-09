# frozen_string_literal: true

module GraphQL
  module Groups
    class QueryBuilder
      def self.parse(lookahead, context, scope)
        QueryBuilder.new(lookahead, context, scope).group_selections
      end

      def initialize(lookahead, context, scope)
        @lookahead = lookahead
        @context = context
        @scope = scope
        super()
      end

      def group_selections(lookahead = @lookahead, parent_info = nil)
        selections = lookahead.selections
        group_selections = selections.select { |selection| selection.field.is_a?(GraphQL::Groups::Schema::GroupField) }
        queries = group_selections.each_with_object([]) do |selection, object|
          object << create_pending_queries(selection, parent_info)
        end
        nested_queries = group_selections
                           .filter { |selection| selection.selects?(:group_by) }
                           .each_with_object([]) do |selection, object|
          parent_info = update_parent_info(parent_info, selection)
          object << group_selections(selection.selection(:group_by), parent_info)
        end
        (queries + nested_queries).flatten
      end

      private

      def create_builder_context(parent_info, selection)
        parent_info ||= { grouping: [], proc: nil }
        parent_info[:grouping].append(selection.name)
        field_proc = proc_from_selection(selection.field, selection.arguments)
        parent_info[:proc] = if parent_info
                               combine_procs(parent_info[:proc], field_proc)
                             else
                               field_proc
                             end
        parent_info
      end

      def create_pending_queries(current_selection, parent_info)
        field_proc = proc_from_selection(current_selection.field, current_selection.arguments)
        base_query = combine_procs(field_proc, parent_info[:proc])
        aggregate_selections = current_selection
                                 .selections
                                 .select { |selection| selection.field.is_a?(GraphQL::Groups::Schema::AggregateField) }
        count_queries = aggregate_selections
                          .select { |selection| selection.name == :count }
                          .map do |selection|
          count_proc = proc { |**kwargs| selection.field.owner.send(:new, {}, nil).public_send(field.query_method, **kwargs) }
          combined = combine_procs(base_query, count_proc)
          PendingQuery.new(current_selection.name, selection.name, combined)
        end
        aggregate_queries = aggregate_selections
                              .select { |selection| selection.field.own_attributes.present? }
                              .map do |selection|
          selection.field.own_attributes.each do |attribute|
            aggregate_proc = proc_from_selection(selection.field, selection.arguments)
            combined = combine_procs(base_query, aggregate_proc)
            PendingQuery.new(current_selection.name, [selection.name, attribute], combined)
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

      def create_pending_query(current_selection, parent_info, aggregate, query)
        return PendingQuery.new(current_selection.name, aggregate, query) unless parent_selection

        new_grouping = parent_info[:grouping].append(current_selection.name)
        PendingQuery.new(new_grouping, aggregate, query)
      end

      def proc_from_selection(field, arguments)
        proc { |**kwargs| field.owner.authorized_new(nil, @context).public_send(field.query_method, **arguments, **kwargs) }
      end
    end
  end
end
