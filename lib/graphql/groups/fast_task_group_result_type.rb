# frozen_string_literal: true

module Types
  class FastTaskGroupResultType < BaseObject
    alias group object

    field :key, String, null: false

    field :count, Integer, null: false

    field :group_by, Types::FastTaskGroupType, null: false, camelize: true

    def key
      group[0]
    end

    def count
      group[1][:count]
    end

    def group_by
      group[1][:nested]
    end
  end
end
