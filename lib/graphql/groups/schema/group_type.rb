# frozen_string_literal: true

require 'graphql'

module GraphQL
  module Groups
    module Schema
      class GroupType < GraphQL::Schema::Object
        include HasGroups

        alias group object

        field_class(GroupField)


      end
    end
  end
end
