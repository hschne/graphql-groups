# GraphQL Groups
[![Gem Version](https://badge.fury.io/rb/graphql-groups.svg)](https://badge.fury.io/rb/graphql-groups)
[![Build Status](https://github.com/hschne/graphql-groups/workflows/Build/badge.svg)](https://github.com/hschne/graphql-groups/workflows/Build/badge.svg)
[![Maintainability](https://api.codeclimate.com/v1/badges/692d4125ac8548fb145e/maintainability)](https://codeclimate.com/github/hschne/graphql-groups/maintainability) 
[![Test Coverage](https://api.codeclimate.com/v1/badges/692d4125ac8548fb145e/test_coverage)](https://codeclimate.com/github/hschne/graphql-groups/test_coverage)

Create flexible and performant aggregation queries with [graphql-ruby](https://github.com/rmosolgo/graphql-ruby).

## Installation

Add this line to your application's Gemfile and run `bundle install`.

```ruby
gem 'graphql-groups'
```
```bash
$ bundle install
```

## Usage

Create a new group type to specify which attributes you wish to group by inheriting from `GraphQL::Groups::GroupType`

```ruby
class AuthorGroupType < GraphQL::Groups::GroupType
  scope { Author.all }

  by :age
end
```

Include the new type in your schema using the `group` keyword. 

```ruby
class QueryType < GraphQL::Schema::Object
  include GraphQL::Groups

  group :author_groups, AuthorGroupType
end
```

You can then run an aggregation query for this grouping. 

```graphql
query myQuery{ 
  authorGroups {
    age {
      key
      count
    }
 }
}
```
```json
{
  "authorGroups":{
    "age":[
      {
        "key":"31",
        "count":1
      },
      {
        "key":"35",
        "count":3
      },
      ...
    ]
  }
}

```

## Advanced Usage

#### Custom Grouping Queries

To customize how items are grouped, you may specify the grouping query by creating a method of the same name in the group type. 

```ruby
class AuthorGroupType < GraphQL::Groups::Schema::GroupType
  scope { Author.all }

  by :age

  def age(scope:)
    scope.group("(cast(age/10 as int) * 10) || '-' || ((cast(age/10 as int) + 1) * 10)")
  end
end
```

You may also pass arguments to custom grouping queries. In this case, pass any arguments to your group query as keyword arguments.

```ruby
class BookGroupType < GraphQL::Groups::Schema::GroupType
  scope { Book.all }

  by :published_at do
    argument :interval, String, required: false
  end

  def published_at(scope:, interval: nil)
    case interval
    when 'month'
      scope.group("strftime('%Y-%m-01 00:00:00 UTC', published_at)")
    when 'year'
      scope.group("strftime('%Y-01-01 00:00:00 UTC', published_at)")
    else
      scope.group("strftime('%Y-%m-%d 00:00:00 UTC', published_at)")
    end
  end
end
```

When defining a group type's scope you may access the parents `object` and `context`. 

```ruby
class QueryType < GraphQL::Schema::Object
  field :statistics, StatisticsType, null: false

  def statistics
    Book.all
  end
end

class StatisticsType < GraphQL::Schema::Object
  include GraphQL::Groups

  group :books, BookGroupType
end

class BookGroupType < GraphQL::Groups::Schema::GroupType
  # `object` refers to `Book.all`
  scope { object.where(author_id: context[:current_person]) }

  by :name
end
```

For more examples see the [feature spec](./spec/graphql/feature_spec.rb) and [test schema](./spec/graphql/support/test_schema)

### Custom Aggregates

Per default `graphql-groups` supports aggregating `count` out of the box. If you need to other aggregates, such as sum or average 
you may add them to your schema by creating a custom `GroupResultType`. Wire this up to your schema by specifying the result type in your
group type.

```ruby
class AuthorGroupResultType < GraphQL::Groups::Schema::GroupResultType
  aggregate :average do
    attribute :age
  end
end
```

```ruby
class AuthorGroupType < GraphQL::Groups::Schema::GroupType
  scope { Author.all }

  result_type { AuthorGroupResultType }

  by :name
end
```

Per default, the aggregate name and attribute will be used to construct the underlying aggregation query. The example above creates
```ruby
scope.average(:age)
```

If you need more control over how to aggregate you may define a custom query by creating a method matching the aggregate name. The method *must* take the keyword arguments `scope` and `attribute`. 

```ruby
class AuthorGroupResultType < GraphQL::Groups::Schema::GroupResultType
  aggregate :average do
    attribute :age
  end

  def average(scope:, attribute:)
    scope.average(attribute)
  end
end
```

For more examples see the [feature spec](./spec/graphql/feature_spec.rb) and [test schema](./spec/graphql/support/test_schema)

## Limitations and Known Issues

*This gem is in early development!* There are a number of issues that are still being addressed. There is no guarantee
that this libraries API will not change fundamentally from one release to the next. Please refer to the [issue tracker](https://github.com/hschne/graphql-groups/issues) for a list of known issues.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/hschne/graphql-groups. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Graphql::Groups project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/graphql-groups/blob/master/CODE_OF_CONDUCT.md).
