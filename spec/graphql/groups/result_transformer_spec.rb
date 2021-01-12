# frozen_string_literal: true

require 'spec_helper'

module GraphQL
  module Groups
    RSpec.describe ResultTransformer do
      describe 'with non-array key' do
        let(:input) {
          [QueryResult.new(:name, :count, { 'first' => 1 })]
        }

        let(:output) {
          { name: {
            'first' => { count: 1 }
          } }
        }

        it 'transforms item' do
          result = described_class.new.run(input)

          expect(result).to eq(output)
        end
      end

      describe 'with null key' do
        let(:input) {
          [QueryResult.new(:name, :count, { nil => 1 })]
        }

        let(:output) {
          { name: {
            nil => { count: 1 }
          } }
        }

        it 'transforms item' do
          result = described_class.new.run(input)

          expect(result).to eq(output)
        end
      end

      describe 'with no results' do
        let(:input) {
          [QueryResult.new(:name, :count, {})]
        }

        let(:output) { { name: [] } }

        it 'returns empty array' do
          result = described_class.new.run(input)

          expect(result).to eq(output)
        end
      end

      describe 'with multiple items' do
        let(:input) {
          [QueryResult.new(:name, :count, { 'first' => 1, 'second' => 2 })]
        }

        let(:output) {
          { name: {
            'first' => { count: 1 },
            'second' => { count: 2 }
          } }
        }

        it 'transforms items' do
          result = described_class.new.run(input)

          expect(result).to eq(output)
        end
      end

      describe 'with nested items' do
        let(:input) {
          [QueryResult.new(%i[name age], :count, { ['first', 1] => 1 })]
        }

        let(:output) {
          { name: {
            'first' => { group_by: {
              age: {
                1 => { count: 1 }
              }
            } }
          } }
        }

        it 'transforms items' do
          result = described_class.new.run(input)

          expect(result).to eq(output)
        end
      end

      describe 'with attribute aggregates' do
        let(:input) {
          [QueryResult.new(:name, %i[average age], { 'first' => 1 })]
        }

        let(:output) {
          { name:
              {
                'first' => {
                  average: {
                    age: 1
                  }
                }
              } }
        }

        it 'transforms items' do
          result = described_class.new.run(input)

          expect(result).to eq(output)
        end
      end
    end
  end
end
