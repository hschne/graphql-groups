# frozen_string_literal: true

module GraphQL
  module Groups
    class LookaheadParser
      def self.parse(base_selection, context)
        # TODO: Raise error if no aggregate selection is made
        LookaheadParser.new(context).group_selections(base_selection, {})
      end

      def initialize(context)
        @context = context
      end

      def group_selections(root, hash)
        selections = root.selections
        group_selections = selections.select { |selection| selection.field.is_a?(GraphQL::Groups::Schema::GroupField) }
        group_selections.each do |selection|
          own_query = get_field_proc(selection.field, selection.arguments)
          hash[selection.name] ||= { proc: own_query }
          hash[selection.name][:aggregates] = aggregates(selection)
        end
        group_selections
          .filter { |selection| selection.selects?(:group_by) }
          .each { |selection| hash[selection.name][:nested] = group_selections(selection.selection(:group_by), {}) }
        hash
      end

      def get_field_proc(field, arguments)
        proc { |**kwargs| field.owner.authorized_new(nil, @context).public_send(field.query_method, **arguments, **kwargs) }
      end

      def aggregates(group_selection)
        aggregate_selections = group_selection.selections.select do |selection|
          selection.field.is_a?(GraphQL::Groups::Schema::AggregateField)
        end
        aggregate_selections.each_with_object({}) do |selection, object|
          name = selection.name
          field = selection.field
          if name == :count
            proc = proc { |**kwargs| field.owner.send(:new, {}, nil).public_send(field.query_method, **kwargs) }
            object[name] = { proc: proc }
          elsif selection.field.own_attributes.present?
            object[name] = { proc: get_aggregate_proc(field, selection.arguments), attributes: field.own_attributes }
          end
        end
      end

      def get_aggregate_proc(field, arguments)
        proc { |**kwargs| field.owner.authorized_new(nil, @context).send(field.query_method, **kwargs, **arguments) }
      end
    end
  end
end
