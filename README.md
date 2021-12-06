[![Gem Version](https://badge.fury.io/rb/filterameter.svg)](https://badge.fury.io/rb/filterameter)
[![RuboCop](https://github.com/RockSolt/filterameter/workflows/RuboCop/badge.svg)](https://github.com/RockSolt/filterameter/actions?query=workflow%3ARuboCop)
[![RSpec](https://github.com/RockSolt/filterameter/workflows/RSpec/badge.svg)](https://github.com/RockSolt/filterameter/actions?query=workflow%3ARSpec)
[![Maintainability](https://api.codeclimate.com/v1/badges/d9d87f9ce8020eb6e656/maintainability)](https://codeclimate.com/github/RockSolt/filterameter/maintainability)

# Filterameter
Declarative filter parameters provide provide clean and clear filters for queries.

## Usage
Declare filters in query classes or controllers to increase readability and reduce boilerplate code. Filters can be declared for attributes, scopes, or attributes from singular associations (`belongs_to` or `has_one`). Validations can also be assigned.

```ruby
  filter :color
  filter :size, validates: { inclusion: { in: %w[Small Medium Large], allow_multiple_values: true } }
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
filter :size, validates: { inclusion: { in: %w[Small Medium Large] } }
```

The `inclusion` validator has been overridden to provide the additional option `allow_multiple_values`. When true, the value can be an array and each entry in the array will be validated. Use this when the filter can specify one or more values.

```ruby
filter :size, validates: { inclusion: { in: %w[Small Medium Large], allow_multiple_values: true } }
```


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

#### range
Specify the range option to enable searches by ranges, minimum values, or maximum values. (All of these are inclusive. A search for a minimum value of $10.00 would include all items priced at $10.00.)

Here are the available options:
- true: enable ranges, minimum values, and/or maximum values
- min_only: enables minimum values
- max_only: enables maximum values

Using the range option means that _in addition to the attribute filter_ minimum and maximum query parameters may also be specified. The parameter names are the attribute name plus the suffix <tt>_min</tt> or <tt>_max</tt>.

```ruby
filter :price, range: true
filter :approved_at, range: :min_only
filter :sale_price, range: :max_only
```

In the first example, query parameters could include <tt>price</tt>, <tt>price_min</tt>, and <tt>price_max</tt>.

### Query Classes

Include module `Filterameter::DeclarativeFilters` in the query class. The model must be declared using `model`, and a default query can optionally be declared using `default_query`. If no default query is provided, then the default is `.all`.

#### Example

Here's what a query class for the Widgets model with filters on size and color might look like:

```ruby
class WidgetQuery
  include Filterameter::DeclarativeFilters

  model Widget
  filter :size
  filter :color
end
```

Build the query using class method `build_query`. The method takes two parameters:

- filter: the hash of filter parameters
- starting_query: any scope to build on (if not provided, the default query is the starting point)

Here's how the query might be invoked:

```ruby
filters = { size: 'large', color: 'blue' }
widgets = WidgetQuery.build_query(filters, Widget.limit(10))
```

### Controllers

Include module `Filterameter::DeclarativeControllerFilters` in the controller. Add before action callback `build_filtered_query` for controller actions that should build the query.

Rails conventions are used to determine the controller's model as well as the name of the instance variable to apply the filters to. For example, the PhotosController will use the variable `@photos` to store a query against the Photo model. **If the conventions do not provide the correct info**, they can be overridden with the following two methods:

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

#### Example

In the happy path, the WidgetsController serves Widgets and can filter on size and color. Here's what the controller might look like:

```ruby
class WidgetController < ApplicationController
  include Filterameter::DeclarativeControllerFilters
  before_action :build_filtered_query, only: :index

  filter :size
  filter :color

  def index
    render json: @widgets
  end
end
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
