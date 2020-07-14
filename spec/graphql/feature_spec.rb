# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Feature', type: :feature do
  describe 'grouping' do
    it 'with default query should return' do
      Author.create(name: 'name', age: 30)

      query = GQLi::DSL.query {
        authorGroups {
          name {
            key
            count
          }
        }
      }.to_gql

      result = GroupsSchema.execute(query)

      group = result['data']['authorGroups']['name'][0]
      expect(group['key']).to eq('name')
      expect(group['count']).to eq(1)
    end

    it 'with custom query should return data' do
      Author.create(name: 'name', age: 35)

      query = GQLi::DSL.query {
        authorGroups {
          age {
            key
            count
          }
        }
      }.to_gql

      result = GroupsSchema.execute(query)

      group = result['data']['authorGroups']['age'][0]
      expect(group['key']).to eq('30-40')
      expect(group['count']).to eq(1)
    end

    it 'with nested query should return' do
      Author.create(name: 'name', age: 30)

      query = GQLi::DSL.query {
        authorGroups {
          name {
            groupBy {
              age {
                key
                count
              }
            }
          }
        }
      }.to_gql

      result = GroupsSchema.execute(query)

      group = result['data']['authorGroups']['name'][0]['groupBy']['age'][0]
      expect(group['key']).to eq('30-40')
      expect(group['count']).to eq(1)
    end

    it 'with average should return data' do
      Author.create(name: 'name', age: 5)
      Author.create(name: 'name', age: 10)

      query = GQLi::DSL.query {
        authorGroups {
          name {
            key
            average {
              age
            }
          }
        }
      }.to_gql

      result = GroupsSchema.execute(query)

      group = result['data']['authorGroups']['name'][0]
      expect(group['key']).to eq('name')
      expect(group['average']['age']).to eq(7.5)
    end

    it 'supports arguments data' do
      author = Author.create(name: 'name')
      time = Time.parse('2020-01-01 00:00:00 UTC')
      Book.create(author: author, published_at: time)

      query = GQLi::DSL.query {
        bookGroups {
          publishedAt(interval: 'day') {
            key
            count
          }
        }
      }.to_gql

      result = GroupsSchema.execute(query)

      group = result['data']['bookGroups']['publishedAt'][0]
      expect(group['key']).to eq(time.to_s)
      expect(group['count']).to eq(1)
    end
  end
end
