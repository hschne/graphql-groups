# frozen_string_literal: true

require 'spec_helper'

module GraphQL
  module Groups
    RSpec.describe GraphQL::Groups::QueryExecutor do
      it 'should return count' do
        author = Author.create(name: 'name', age: 1)
        query  = { age: { aggregate: :count } }

        result = GraphQL::Groups::QueryExecutor.run(Author.all, query)

        expect(result.dig(:age, author.age, :count)).to eq(1)
      end
    end
  end
end
