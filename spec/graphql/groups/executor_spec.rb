# frozen_string_literal: true

require 'spec_helper'

module GraphQL
  module Groups
    RSpec.describe Executor do
      describe 'with aggregates' do
        it 'returns count' do
          author = Author.create(name: 'name', age: 1)
          group_proc = proc { |scope:| scope.group(:age) }
          aggregate_proc = proc { |scope:| scope.count }
          execution_plan = { age: { proc: group_proc, aggregates: { count: { proc: aggregate_proc } } } }

          result = described_class.call(Author.all, execution_plan)

          expect(result.dig(:age, :count, author.age)).to eq(1)
        end
      end
    end
  end
end

