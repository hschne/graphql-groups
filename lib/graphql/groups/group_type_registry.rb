# frozen_string_literal: true

require 'singleton'

module GraphQL
  module Groups
    class GroupTypeRegistry
      include Singleton

      attr_reader :types

      def initialize
        @types = {}
      end

      def clear
        @types = {}
      end

      def register(type, derived)
        types[type] = derived
      end

      def get(type)
        types[type]
      end
    end
  end
end
