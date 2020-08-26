# frozen_string_literal: true

require 'spec_helper'

module GraphQL
  module Groups
    RSpec.describe ResultTransformer do
      describe 'with non-array key' do
        let(:input) {
          { name: { count: {
            'first' => 1
          } } }
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
          { name: { count: {
            nil => 1
          } } }
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
          { name: { count: {
          } } }
        }

        let(:output) { { name: [] } }

        it 'returns empty array' do
          result = described_class.new.run(input)

          expect(result).to eq(output)
        end
      end

      describe 'with multiple items' do
        let(:input) {
          { name: { count: {
            ['first'] => 1,
            ['second'] => 2
          } } }
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
          { %i[name age] => { count: {
            %w[first 10] => 1,
            %w[first 20] => 1
          } } }
        }

        let(:output) {
          { name: {
            'first' => { nested: {
              age: {
                '10' => { count: 1 },
                '20' => { count: 1 }
              }
            } }
          } }
        }

        it 'transforms items' do
          result = described_class.new.run(input)

          expect(result).to eq(output)
        end
      end

      describe 'with attribute based aggregate' do
        let(:input) {
          { name: { average: {
            age: {
              'first' => 10,
              'second' => 10
            }
          } } }
        }

        let(:output) {
          { name: {
            'first' => { average: { age: 10 } },
            'second' => { average: { age: 10 } }
          } }
        }

        it 'transforms item' do
          result = described_class.new.run(input)

          expect(result).to eq(output)
        end
      end
    end
  end
end
