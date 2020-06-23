# frozen_string_literal: true
module GraphQL
  module Groups
    class LookaheadParser
      def self.parse(base_selection)
        LookaheadParser.new.group_selections(base_selection, {})
      end

      def group_selections(root, hash)
        selections = root.selections
        group_selections = selections.select { |selection| selection.field.is_a?(GraphQL::Groups::Schema::GroupField) }
        group_selections.each do |selection|
          own_query = selection.field.own_query
          hash[selection.name] ||= { proc: own_query }
          hash[selection.name][:aggregates] = aggregates(selection)
        end
        group_selections
          .filter { |selection| selection.selects?(:group_by) }
          .each { |selection| hash[selection.name][:nested] = group_selections(selection.selection(:group_by), {}) }
        hash
      end

      def aggregates(group_selection)
        aggregate_selections = group_selection.selections.select { |selection| selection.field.is_a?(GraphQL::Groups::Schema::AggregateField) }
        aggregate_selections.each_with_object({}) do |selection, object|
          name = selection.name
          field = selection.field
          if name == :count
            object[name] = { proc: field.own_query }
          elsif selection.field.own_attributes.present?
            object[name] = { proc: field.own_query, attributes: field.own_attributes }
          end
        end
      end
    end
  end
end
