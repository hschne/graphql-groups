# frozen_string_literal: true

module GraphQL
  module Groups
    module Utils
      class << self
        def wrap(object)
          if object.nil?
            []
          elsif object.respond_to?(:to_ary)
            object.to_ary || [object]
          else
            [object]
          end
        end

        # This is used by the resul transformer when the user executed a query where some groupings are repeated, so depth
        # of the query doesn't match the length of the query result keys. We need to modify the result keys so everything
        # matches again.
        def duplicate(keys, values)
          return if keys.length == values.length

          duplicates = duplicates(keys)
          return if duplicates.empty?

          duplicates.each do |_, indices|
            first_occurrence, *rest = indices
            value_to_duplicate = values[first_occurrence]
            rest.each { |index| values.insert(index, value_to_duplicate) }
          end
        end

        private

        def duplicates(array)
          map = {}
          duplicates = {}
          array.each_with_index do |v, i|
            map[v] = (map[v] || 0) + 1
            duplicates[v] ||= []
            duplicates[v] << i
          end
          duplicates.select { |_, v| v.length > 1 }
        end

      end
    end
  end
end
