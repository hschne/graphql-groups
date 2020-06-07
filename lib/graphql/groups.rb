require "graphql/groups/version"
require 'graphql/groups/query_executor'
require 'graphql/groups/lookahead_parser'

module Graphql
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

      def group(name, type: null, &block)
        # Add implementation here
      end

      def scope(&block)
        config[:result] = block
      end

      def result(&block)
        config[:result] = block
      end
    end
  end
end
