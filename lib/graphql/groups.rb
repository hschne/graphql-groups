# frozen_string_literal: true

require 'graphql/groups/version'
require 'graphql/groups/query_executor'
require 'graphql/groups/lookahead_parser'

require 'graphql/groups/group_type'

module GraphQL
  module Groups
    def self.included(base)
      base.extend ClassMethods
      base.instance_eval do
        @config = {
          defaults: {},
          options:  {}
        }
      end
    end

    module ClassMethods
      KEYS = %i[type default description required camelize].freeze

      def group(name, type, **options)
        field name, type, extras: [:lookahead], null: false, **options

        define_method name do |lookahead: nil|
          type.execute(lookahead)
        end
      end
    end
  end
end
