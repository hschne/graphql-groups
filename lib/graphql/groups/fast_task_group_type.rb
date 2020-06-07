# frozen_string_literal: true

module Types
  class FastTaskGroupType < BaseObject
    alias group object

    field :section_id, [FastTaskGroupResultType], null: false, camelize: true

    field :created_at, [FastTaskGroupResultType], null: false, camelize: true

    def section_id
      group[:section_id]
    end

    def created_at
      group[:created_at]
    end
  end
end
