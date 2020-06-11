# GraphQL Groups

Create flexible and performant aggregation queries with [graphql-ruby](https://github.com/rmosolgo/graphql-ruby)

## Installation

Add this line to your application's Gemfile and execute bundler.

```ruby
gem 'graphql-groups'
```
```
$ bundle install
```

## Usage

Create a new group type to specify which attributes you wish to group a model by.

```
class AuthorGroupType < GraphQL::Groups::GroupType
  scope { Author.all }

  by :age
end
```

Include the new type in your schema using the `group` keyword. 

```
class QueryType < BaseType
  include GraphQL::Groups

  group :author_groups, AuthorGroupType
```

You can then run an aggregation query for this grouping. 

```graphql
query { 
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


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/graphql-groups. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Graphql::Groups project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/graphql-groups/blob/master/CODE_OF_CONDUCT.md).
