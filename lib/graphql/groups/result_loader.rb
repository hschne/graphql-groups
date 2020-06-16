# frozen_string_literal: true

module GraphQL
  module Groups
    class ResultLoader
      def initialize(type)
        @type = type
        context = type.context
        @executor = context[:group_executor] ||= Executor.new
      end

      def with(key, &block)
        @executor.append(key, block)
      end

      # Return the loaded record, hitting the database if needed
      def load
        result = @executor.fetch(@type, key)
      end
    end
  end
end
