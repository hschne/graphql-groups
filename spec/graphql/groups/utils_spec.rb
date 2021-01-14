# frozen_string_literal: true

require 'spec_helper'

module GraphQL
  module Groups
    RSpec.describe Utils do
      describe 'wrap' do
        it 'wraps single value' do
          result = described_class.wrap(1)

          expect(result).to eq([1])
        end

        it 'wraps array' do
          result = described_class.wrap([1])

          expect(result).to eq([1])
        end
      end

      describe 'duplicate' do
        it 'duplicates sequential values' do
          keys = %i[name name name]
          values = ['name']
          described_class.duplicate(keys, values)

          expect(values).to eq(%w[name name name])
        end

        it 'duplicates interspersed values' do
          keys = %i[name age name]
          values = ['name', 1]
          described_class.duplicate(keys, values)

          expect(values).to eq(['name', 1, 'name'])
        end

        it 'duplicates multiple interspersed values' do
          keys = %i[name age name age]
          values = ['name', 1]
          described_class.duplicate(keys, values)

          expect(values).to eq(['name', 1, 'name', 1])
        end
      end
    end
  end
end
