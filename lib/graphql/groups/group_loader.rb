# frozen_string_literal: true

module GraphQL
  module Groups
    class GroupLoader
      def initialize(context)
        @group_state = context[:group_executor] ||= Executor.new
      end

      class << self
        def with(key, &block)

        end
      end

      # Return the loaded record, hitting the database if needed
      def load

      end
    end
  end
end
