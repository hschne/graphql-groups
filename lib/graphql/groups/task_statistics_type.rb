# frozen_string_literal: true

module Types
  class TaskStatisticsType < BaseObject
    alias tasks object

    field :count, Integer, null: false

    field :group_by, Types::TaskGroupType, null: false, camelize: true

    field :fast_group_by, Types::FastTaskGroupType, null: false, camelize: true, extras: [:lookahead]

    def count
      tasks.size
    end

    def group_by
      tasks
    end

    def fast_group_by(lookahead:)
      query = selections_to_hash(lookahead)
      TaskStatistics.new.collect(tasks, query)
    end

    private

    # Convert the GraphQL query to a generic representation of the required database queries. The generic representation
    # contains the information about required aggregates (e.g. count, sum) and which groups (e.g. by section). This conversion
    # happens in order to provide a decoupling of GraphQL from the statistics collection logic.
    def selections_to_hash(base_selection)
      selections = base_selection.selections
      groupings  = {}
      selections.each do |selection|
        if selection.selects?(:count)
          groupings[selection.name] ||= {}
          groupings[selection.name][:aggregate] = :count
        end
        if selection.selects?(:group_by)
          groupings[selection.name] ||= {}
          groupings[selection.name][:nested] = selections_to_hash(selection.selection(:group_by))
        end
      end
      groupings
    end
  end
end
