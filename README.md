[![Gem Version](https://badge.fury.io/rb/filterameter.svg)](https://badge.fury.io/rb/filterameter)

# Filterameter
Declarative Filter Parameters for Rails Controllers.

## Usage
Declare filters at the top of controllers to increase readability and reduce boilerplate code. Filters can be declared for attributes, scopes, or attributes from singular associations (`belongs_to` or `has_one`). Validations can also be assigned.

```ruby
  filter :color
  filter :size, validates: { inclusion: { in: %w[Small Medium Large] }, unless: -> { size.is_a? Array } }
  filter :brand_name, association: :brand, name: :name
  filter :on_sale, association: :price, validates: [{ numericality: { greater_than: 0 } },
                                                    { numericality: { less_than: 100 } }]
```

### Filtering Options

The following options can be specified for each filter.

#### name
If the name of the parameter is different than the name of the attribute or scope, then use the name parameter to specify the name of the attribute or scope. For example, if the attribute name is `current_status` but the filter is exposed simply as `status` use the following:

```ruby
filter :status, name: :current_status
```

#### association
If the attribute or scope is nested, it can be referenced by naming the association. Only singular associations are valid. For example, if the manager_id attribute lives on an employee's department record, use the following:

```ruby
filter :manager_id, association: :department
```

#### validates
If the filter value should be validated, use the `validates` option along with [ActiveModel validations](https://api.rubyonrails.org/classes/ActiveModel/Validations/ClassMethods.html#method-i-validates). Here's an example of the inclusion validator being used to restrict sizes:

```ruby
filter :size, validates: { inclusion: { in: %w[Small Medium Large] }, unless: -> { size.is_a? Array } }
```

Note that the `inclusion` validator does not allow arrays to be specified. If the filter should allow multiple values to be specified, then the validation needs to be disabled when the value an array.

#### partial
Specify the partial option if the filter should do a partial search (SQL's `LIKE`). The partial option accepts a hash to specify the search behavior. Here are the available options:
- match: anywhere (default), from_start, dynamic
- case_sensitive: true, false (default)

There are two shortcuts: : the partial option can be declared with `true`, which just uses the defaults; or the partial option can be declared with the match option directly, such as `partial: :from_start`.

```ruby
filter :description, partial: true
filter :department_name, partial: :from_start
filter :reason, partial: { match: :dynamic, case_sensitive: true } 
```

The `match` options defines where you are searching (which then controls where the wildcard(s) appear):
- anywhere: adds wildcards at the start and end, for example '%blue%'
- from_start: adds a wildcard at the end, for example 'blue%'
- dynamic: adds no wildcards; this enables the client to fully control the search string

### Configuring Controllers

Rails conventions are used to determine the controller's model as well as the name of the instance variable to apply the filters to. For example, the PhotosController will use the variable `@photos` to store a query against the Photo model. If the conventions do not provide the correct info, they can be overridden with the following two methods:

#### filter_model
Provide the name of the model. This method also allows the variable name to be optionally provided as the second parameter.

```ruby
filter_model 'Picture'
```

#### filter_query_var_name
Provide the name of the instance variable. For example, if the query is stored as `@data`, use the following:

```ruby
filter_query_var_name :data
```

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'filterameter'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install filterameter
```


## Running Tests

Tests are written in RSpec and the dummy app uses a docker database. First, start the database and prepare it from the dummy folder.

```bash
cd spec/dummy
docker-compose up -d
bundle exec rails db:test:prepare
cd ../..
```

Run the tests from the main directory

```bash
bundle exec rspec
```

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
