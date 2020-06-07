# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Graphql::Groups do
  describe 'using graphql' do
    it 'should return data' do
      author = Author.create(name: 'name')

      query = GQLi::DSL.query {
        authors {
          name
        }
      }.to_gql

      result = GroupsSchema.execute(query)

      result_name = result['data']['authors'][0]['name']
      expect(result_name).to eq(author.name)
    end
  end
end

# class TaskStatisticsTest
#   test 'collect count by section id returns count' do
#     task  = create(:task)
#     query = { section_id: { aggregate: :count } }
#
#     result = QueryExecutor.new.run(Task.all, query)
#
#     assert(1, result.dig(:section_id, task.section_id, :count))
#   end
#
#   test 'collect count by created at returns count' do
#     travel_to(Time.zone.parse('2020-01-01')) do
#       create(:task)
#     end
#
#     query = { created_at: { aggregate: :count } }
#
#     result = QueryExecutor.new.run(Task.all, query)
#
#     assert(1, result.dig(:section_id, '2020-01-01', :count))
#   end
#
#   test 'collect count for nested query returns count' do
#     travel_to(Time.zone.parse('2020-01-01'))
#     first, second = create_list(:task, 2)
#     travel_back
#     query = {
#       section_id: {
#         aggregate: :count,
#         nested: {
#           created_at: {
#             aggregate: :count
#           }
#         }
#       }
#     }
#
#     result = QueryExecutor.new.run(Task.all, query)
#
#     assert(2, result.dig(:section_id, first.section_id, :count))
#     first_nested = result.dig(:section_id, first.section_id, :nested)
#     assert(1, first_nested.dig(:created_at, '2020-01-01', :count))
#     second_nested = result.dig(:section_id, second.section_id, :nested)
#     assert(1, second_nested.dig(:created_at, '2020-01-01', :count))
#   end
# end
