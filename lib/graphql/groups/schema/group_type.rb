# frozen_string_literal: true

require 'graphql'

module GraphQL
  module Groups
    module Schema
      class GroupType < GraphQL::Schema::Object
        include HasGroups

        alias group object

        # TODO: Make group field inherit from default field, so that users default args/fields are respected
        field_class(GroupField)
      end
    end
  end
end
