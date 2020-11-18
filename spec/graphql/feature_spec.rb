# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'feature', type: :feature do
  describe 'grouping' do
    it 'with default query should return' do
      Author.create(name: 'a', age: 30)
      Author.create(name: 'b', age: 30)

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
      expect(group['key']).to eq('a')
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
            key
            count
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

    it 'supports using object in scope' do
      author = Author.create(name: 'name')
      Book.create(author: author, name: 'name')

      query = GQLi::DSL.query {
        statistics {
          books {
            name {
              key
              count
            }
          }
        }
      }.to_gql

      result = GroupsSchema.execute(query)

      group = result['data']['statistics']['books']['name'][0]
      expect(group['key']).to eq('name')
      expect(group['count']).to eq(1)
    end

    it 'supports arguments data' do
      author = Author.create(name: 'name')
      time = Time.parse('2020-01-01 00:00:00 UTC')
      Book.create(author: author, published_at: time)

      query = GQLi::DSL.query {
        statistics {
          books {
            publishedAt(interval: 'day') {
              key
              count
            }
          }
        }
      }.to_gql

      result = GroupsSchema.execute(query)

      group = result['data']['statistics']['books']['publishedAt'][0]
      expect(group['key']).to eq(time.to_s)
      expect(group['count']).to eq(1)
    end

    it 'performs well with large hashes' do
      author = Author.create(name: 'name')
      # Groupdate will fill the space between the dates automatically, which results in ginormous result sets for the
      # queries
      Book.create(author: author, published_at: Time.parse('1970-01-01 00:00:00 UTC'))
      Book.create(author: author, published_at: Time.parse('2020-01-01 00:00:00 UTC'))

      query = GQLi::DSL.query {
        statistics {
          books {
            publishedAt(interval: 'day') {
              key
              count
            }
          }
        }
      }.to_gql

      require 'timeout'
      result = Timeout.timeout(3) { GroupsSchema.execute(query) }

      group = result['data']['statistics']['books']['publishedAt'][0]
      expect(group['key']).to eq('2020-01-01')
      expect(group['count']).to eq(1)
    end
  end
end
