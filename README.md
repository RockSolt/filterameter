[![Gem Version](https://badge.fury.io/rb/filterameter.svg)](https://badge.fury.io/rb/filterameter)
[![RuboCop](https://github.com/RockSolt/filterameter/workflows/RuboCop/badge.svg)](https://github.com/RockSolt/filterameter/actions?query=workflow%3ARuboCop)
[![RSpec](https://github.com/RockSolt/filterameter/workflows/RSpec/badge.svg)](https://github.com/RockSolt/filterameter/actions?query=workflow%3ARSpec)

# Filterameter
Filterameter provides declarative filters for Rails controllers to reduce boilerplate code and increase readability. How many times have you seen (or written) this controller action?

```ruby
def index
  @films = Films.all
  @films = @films.where(name: params[:name]) if params[:name]
  @films = @films.joins(:film_locations).merge(FilmLocations.where(location_id: params[:location_id])) if params[:location_id]
  @films = @films.directed_by(params[:director_id]) if params[:director_id]
  @films = @films.written_by(params[:writer_id]) if params[:writer_id]
  @films = @films.acted_by(params[:actor_id]) if params[:actor_id]
end
```

It's redundant code and a bit of a pain to write and maintain. Not to mention what RuboCop is going to say about it. Wouldn't it be nice if you could just declare the filters that the controller accepts?

```ruby
  filter :name, partial: true
  filter :location_id, association: :film_locations
  filter :director_id, name: :directed_by
  filter :writer_id, name: :written_by
  filter :actor_id, name: :acted_by

  def index
    @films = build_query_from_filters
  end
```

Simplify and speed development of Rails controllers by making filter parameters declarative with Filterameter.

## Table of Contents
- [Getting Started](#getting-started)
- [Usage](#usage)
  - [Filtering Options](#filtering-options)
    - [Name](#name)
    - [Association](#association)
    - [Validates](#validates)
    - [Partial](#partial)
    - [Range](#range)
    - [Sortable](#sortable)
  - [Scope Filters](#scope-filters)
  - [Sorting](#sorting)
  - [Building the Query](#building-the-query)
  - [Specifying the Model](#specifying-the-model)
- [Configuration](#configuration)
- [Testing Declarations](#testing-declarations)
- [Forms and Query Parameters](#forms-and-query-parameters)
- [Contribute](#contribute)
- [License](#license)

## Getting Started

This gem requires Rails 6.1+, and works with ActiveRecord.

### Installation
Add this line to your application's Gemfile:

```ruby
gem 'filterameter'
```

And then execute:
```bash
$ bundle install
```

Or install it yourself as:
```bash
$ gem install filterameter
```

## Usage
Include module `Filterameter::DeclarativeFilters` in the controller to provide the filter DSL. It can be included in the `ApplicationController` to make the functionality available to all controllers or it can be mixed in on a case-by-case basis.

```ruby
  filter :color
  filter :size, validates: { inclusion: { in: %w[Small Medium Large], allow_multiple_values: true } }
  filter :brand_name, association: :brand, name: :name
  filter :on_sale, association: :price, validates: [{ numericality: { greater_than: 0 } },
                                                    { numericality: { less_than: 100 } }]
```

Filters without options can be declared all at once with `filters`:

```ruby
filters :color,
        :size,
        :name
```

### Filtering Options

The following options can be specified for each filter.

#### name
If the name of the parameter is different than the name of the attribute or scope, then use the name parameter to specify the name of the attribute or scope. For example, if the attribute name is `current_status` but the filter is exposed simply as `status` use the following:

```ruby
filter :status, name: :current_status
```

This option can also be helpful with nested filters so that the query parameter can be prefixed with the model name. See the `association` option for an example.

#### association
If the attribute or scope is nested, it can be referenced by naming the association. For example, if the manager_id attribute lives on an employee's department record, use the following:

```ruby
filter :manager_id, association: :department
```

The attribute or scope can be nested more than one level. Declare the filter with an array specifying the associations in order. For example, if an employee belongs to a department and a department belongs to a business unit, use the following to query on the business unit name:

```ruby
filter :business_unit_name, name: :name, association: [:department, :business_unit]
```

If an association is a `has_many` [the distinct method](https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-distinct) is called on the query.

_Limitation:_ If there is more than one association to the same table _and_ both associations can be part of the query, then you cannot use a nested filter directly. Instead, build a scope that disambiguates the associations then build a filter against that scope.

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

#### sortable

By default most filters are sortable. To prevent an attribute filter from being sortable, set the option to false.

```ruby
filter :price, sortable: false
```

The following filters are not sortable:

- scope filters (see [_Sorting with a Scope_](#sorting-with-a-scope))
- filters with collection associations


### Scope Filters

For scopes that do not take arguments, the filter should provide a boolean that indicates whether or not the scope should be invoked. For example, imagine a scope called `high_priority` with criteria that identifies high priority records. The scope would be invoked by the query parameters `high_priority=true`.

Passing `high_priority=false` will not invoke the scope. This makes it easy to include a filter with a check box UI.

Scopes that do take arguments [must be written as class methods, not inline scopes.](https://guides.rubyonrails.org/active_record_querying.html#passing-in-arguments) For example, imagine a scope called `recent` that takes an as of date as an argument. Here is what that might look like:

```ruby
def self.recent(as_of_date)
  where('created_at > ?', as_of_date)
end
```

### Sorting

As noted above, most attribute filters are sortable by default. If no filter has been declared for an attribute, the `sort` declaration can be used. Use the same `name` and `association` options as needed.

For example, the following declaration could be used on an activity controller to allow activities to be sorted by project created at.

```ruby
sort :project_created_at, name: :created_at, association: :project
```

Sorts without options can be declared all at once with `sorts`:

```ruby
sorts :created_at,
      :updated_at,
      :description
```

#### Sorting with a Scope

Scopes can be used for sorting, but must be declared with `sort` (or `sorts`). For example, if a model included a scope called `by_created_at` you could add the following to the controller to expose it.

```ruby
sort :by_created_at
```

The `name` and `association` options can also be used. For example, if the scope was on the Project model it could also be used on a child Activity controller using the `association` option:

```ruby
sort :by_created_at, association: :project
```

Only singular associations are valid for sorting. A collection association could return multiple values, making the sort indeterminate.

A scope that is used for sorting must accept a single argument. It will be passed either `:asc` or `:desc` depending on the parameter.

The example scope above might be defined as follows:

```ruby
def self.by_created_at(dir)
  order(created_at: dir)
end
```

#### Default Sort

A default sort can be declared using `default_sort`. The argument(s) should specify one or more of the declared sorts or sortable filters by name. The sorts should be defined as key-value pairs, with the name as the key and the direction as the value.

```ruby
default_sort updated_at: :desc, description: :asc
```

In order to provide consistent results, a sort is always applied. If no default is specified, it will use primary key descending.

### Building the Query

There are two ways to apply the filters and build the query, depending on how much control and/or visibility is desired:

- Use the `build_filtered_query` before action callback
- Manually call `build_query_from_filters`


#### Use the `build_filtered_query` before action callback

Add before action callback `build_filtered_query` for controller actions that should build the query. This can be done either in the `ApplicationController` or on a case-by-case basis.

When using the callback, the variable name is the pluralized model name. For example, the Photo model will use the variable `@photos` to store the query. The variable name can be explicitly specified with with `filter_query_var_name`. For example, if the query is stored as `@data`, use the following:

```ruby
filter_query_var_name :data
```

Additionally, the `filter_model` command takes an optional second parameter to specify the variable name. Both the model and the variable name can be specified with this short-cut. For example, to use the Picture model and store the results as `@data`, use the following:

```ruby
filter_model 'Picture', :data
```

##### Example

In the happy path, the WidgetsController serves Widgets and can filter on size and color. Here's what the controller might look like:

```ruby
class WidgetsController < ApplicationController
  include Filterameter::DeclarativeFilters
  before_action :build_filtered_query, only: :index

  filter :size
  filter :color

  def index
    render json: @widgets
  end
end
```

#### Manually call `build_query_from_filters`

To generate the query manually, you can call `build_query_from_filters` directly _instead of using the callback_.

###### Example

Here's the Widgets controller again, this time building the query manually:

```ruby
class WidgetsController < ApplicationController
  include Filterameter::DeclarativeFilters

  filter :size
  filter :color

  def index
    @widgets = build_query_from_filters
  end
end
```

This method optionally takes a starting query. If there was a controller for Active Widgets that should only return active widgets, the following could be passed into the method as the starting point:

```ruby
  def index
    @widgets = build_query_from_filters(Widget.where(active: true))
  end
```

The starting query is also a good place to provide any includes to enable eager loading:

```ruby
  def index
    @widgets = build_query_from_filters(Widgets.includes(:manufacturer))
  end
```

Note that the starting query provides the model, so the model is not looked up and the `model_name` declaration in not needed.

### Specifying the Model

Rails conventions are used to determine the controller's model. For example, the PhotosController builds a query against the Photo model. If a controller is namespaced, the model will first be looked up without the namespace, then with the namespace.

**If the conventions do not provide the correct model**, the model can be named explicitly with the following:

```ruby
filter_model 'Picture'
```

_Important:_ If the `filter_model` declaration is used, it must be before any filter or sort declarations.

## Configuration

There are three configuration options:

- action_on_undeclared_parameters
- action_on_validation_failure
- filter_key

The configuration options can be set in an initializer, an environment file, or in `application.rb`.

The options can be set directly...

`Filterameter.configuration.action_on_undeclared_parameters = :log`

...or the configuration can be yielded:

```ruby
Filterameter.configure do |config|
  config.action_on_undeclared_parameters = :log
  config.action_on_validation_failuer = :log
  config.filter_key = :f
end
```

#### Action On Undeclared Parameters

Occurs when the filter parameter contains any keys that are not defined. Valid actions are `:log`, `:raise`, and `false` (do not take action). By default, development will log, test will raise, and production will do nothing.

#### Action on Validation Failure

Occurs when a filter parameter fails a validation. Valid actions are `:log`, `:raise`, and `false` (do not take action). By default, development will log, test will raise, and production will do nothing.

#### Filter Key

By default, the filter parameters are nested under the key `:filter`. Use this setting to override the key.

If the filter parameters are NOT nested, set this to false. Doing so will restrict the filter parameters to only
those that have been declared, meaning undeclared parameters are ignored (and the action_on_undeclared_parameters
configuration option does not come into play).

## Testing Declarations

The declarations can be tested for each controller, catching typos, incorrectly defined scopes, or any other issues. Method `declarations_validator` is added to each controller, and a single controller test can be added to validate all the declarations for that controller.

An RSpec test might look like this:

```ruby
expect(WidgetsController.declarations_validator).to be_valid
```

In Minitest it might look like this:

```ruby
validator = WidgetsController.declarations_validator
assert_predicate validator, :valid?, -> { validator.errors }
```

## Forms and Query Parameters

The filter parameters are pulled from the controller parameters, nested under the key `filter` (by default; see [Configuration](#configuration) to change the filter key). For example a request for large, blue widgets might have the following query parameters on the url:

```
?filter[size]=large&filter[color]=blue
```

On [a generic search form](https://guides.rubyonrails.org/form_helpers.html#a-generic-search-form), the [`form_with` form helper takes the option `scope`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html#method-i-form_with) that allows parameters to be grouped:

```erb
<%= form_with url: "/search", scope: :filter, method: :get do |form| %>
  <%= form.label :size, "Size:" %>
  <%= form.text_field :size %>
  <%= form.label :color, "Color:" %>
  <%= form.text_field :color %>
  <%= form.submit "Search" %>
<% end %>
```

#### Sort Parameters

The sort is also nested underneath the filter key:

`/widgets?filter[sort]=size`

Use an array to pass multiple sorts. The order of the parameters is the order the sorts will be applied. For example, the following sorts first by size then by color:

`/widgets?filter[sort][]=size&filter[sort][]=color`

Sorts are ascending by default, but can use a prefix can be added to control the sort:

- `+` ascending (the default)
- `-` descending

For example, the following sorts by size descending:

`/widgets?filter[sort]=-size`

## Contribute

Feedback, feature requests, and proposed changes are welcomed. Please use the [issue tracker](https://github.com/RockSolt/filterameter/issues)
for feedback and feature requests. To propose a change directly, please fork the repo and open a pull request. Keep an eye on the actions to make
sure the tests and Rubocop are passing. [Code Climate](https://codeclimate.com/github/RockSolt/filterameter) is also used manually to assess the codeline.

To report a bug, please use the [issue tracker](https://github.com/RockSolt/filterameter/issues) and provide the following information:

- the version in use
- the filter declarations
- the SQL generated (for invalid / incorrect queries)

Gold stars will be awarded if you are able to [replicate the issue with a test](spec/README.md).

### Running Tests

Tests are written in RSpec and the dummy app uses a docker database. The script `bin/start_db.sh` starts and prepares the test
database. It is a one-time step before running the tests.

```bash
bin/start_db.sh
bundle exec rspec
```

The tests can also be run across all the ruby and Rails combinations using appraisal. The install is also a one-time step.

```bash
bundle exec appraisal install
bundle exec appraisal rspec
```

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
