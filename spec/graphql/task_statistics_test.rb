# frozen_string_literal: true

require 'test_helper'

class TaskStatisticsTest < ActiveSupport::TestCase
  test 'collect count by section id returns count' do
    task  = create(:task)
    query = { section_id: { aggregate: :count } }

    result = TaskStatistics.new.collect(Task.all, query)

    assert(1, result.dig(:section_id, task.section_id, :count))
  end

  test 'collect count by created at returns count' do
    travel_to(Time.zone.parse('2020-01-01')) do
      create(:task)
    end

    query = { created_at: { aggregate: :count } }

    result = TaskStatistics.new.collect(Task.all, query)

    assert(1, result.dig(:section_id, '2020-01-01', :count))
  end

  test 'collect count for nested query returns count' do
    travel_to(Time.zone.parse('2020-01-01'))
    first, second = create_list(:task, 2)
    travel_back
    query = {
      section_id: {
        aggregate: :count,
        nested: {
          created_at: {
            aggregate: :count
          }
        }
      }
    }

    result = TaskStatistics.new.collect(Task.all, query)

    assert(2, result.dig(:section_id, first.section_id, :count))
    first_nested = result.dig(:section_id, first.section_id, :nested)
    assert(1, first_nested.dig(:created_at, '2020-01-01', :count))
    second_nested = result.dig(:section_id, second.section_id, :nested)
    assert(1, second_nested.dig(:created_at, '2020-01-01', :count))
  end
end
