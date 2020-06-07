# frozen_string_literal: true
module GraphQL
  module Groups
    class LookaheadParser
      def self.parse(base_selection)
        selections = base_selection.selections
        groupings  = {}
        selections.each do |selection|
          if selection.selects?(:count)
            groupings[selection.name]             ||= {}
            groupings[selection.name][:aggregate] = :count
          end
          if selection.selects?(:group_by)
            groupings[selection.name]          ||= {}
            groupings[selection.name][:nested] = selections_to_hash(selection.selection(:group_by))
          end
        end
        groupings
      end
    end
  end

end
