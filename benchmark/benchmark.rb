# frozen_string_literal: true

require 'graphql/groups'

require 'database_cleaner/active_record'
require 'gqli/dsl'
require 'benchmark/ips'
require 'gruff'

require_relative '../spec/graphql/support/test_schema/db'
require_relative '../spec/graphql/support/test_schema/models'
require_relative 'benchmark_schema'

class Compare
  def run
    puts 'Generating reports...'
    datasets = perform_runs
    labels = { 0 => '10', 1 => '100', 2 => '1000', 3 => '10000' }
    puts 'Generating graph...'
    graph = graph(labels, datasets)
    graph.write('benchmark/benchmark.jpg')
    puts 'Done!'
  end

  private

  def perform_runs
    runs = [10, 100, 1000, 10_000]
    runs.map { |count| single_run(count) }
      .map(&:data)
      .map { |data| { groups: data.first[:ips], group_by: data.second[:ips] } }
      .each_with_object({ groups: [], group_by: [] }) do |item, object|
      object[:groups].push(item[:groups])
      object[:group_by].push(item[:group_by])
    end
  end

  def graph(labels, datasets)
    g = Gruff::Bar.new(800)
    g.title = 'graphql-groups vs group_by'
    g.theme = Gruff::Themes::THIRTYSEVEN_SIGNALS
    g.labels = labels
    g.x_axis_label = 'records'
    g.y_axis_label = 'iterations/second'
    datasets.each do |data|
      g.data(data[0], data[1])
    end
    g
  end

  def single_run(count)
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.start
    seed(count)
    report = run_benchmark
    DatabaseCleaner.clean
    report
  end

  def seed(count)
    names = %w[Ada Alice Bob Bruce]
    count.times { Author.create(name: names.sample) }
  end

  def groups_query
    GQLi::DSL.query {
      fastGroups {
        name {
          key
          count
        }
      }
    }.to_gql
  end

  def naive_query
    GQLi::DSL.query {
      slowGroups {
        name {
          key
          count
        }
      }
    }.to_gql
  end

  def run_benchmark
    Benchmark.ips(quiet: true) do |x|
      # Configure the number of seconds used during
      # the warmup phase (default 2) and calculation phase (default 5)
      x.config(time: 2, warmup: 1)

      x.report('groups') { PerformanceSchema.execute(groups_query) }

      x.report('group-by') { PerformanceSchema.execute(naive_query) }

      # Compare the iterations per second of the various reports!
      x.compare!
    end
  end
end
