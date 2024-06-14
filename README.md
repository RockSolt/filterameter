[![Gem Version](https://badge.fury.io/rb/filterameter.svg)](https://badge.fury.io/rb/filterameter)
[![RuboCop](https://github.com/RockSolt/filterameter/workflows/RuboCop/badge.svg)](https://github.com/RockSolt/filterameter/actions?query=workflow%3ARuboCop)
[![RSpec](https://github.com/RockSolt/filterameter/workflows/RSpec/badge.svg)](https://github.com/RockSolt/filterameter/actions?query=workflow%3ARSpec)
[![Maintainability](https://api.codeclimate.com/v1/badges/d9d87f9ce8020eb6e656/maintainability)](https://codeclimate.com/github/RockSolt/filterameter/maintainability)

# Filterameter
Declarative filter parameters provide clean and clear filters for Rails controllers.

## Usage
Declare filters in controllers to increase readability and reduce boilerplate code. Filters can be declared for attributes or scopes, either directly on the model or on an associated model. Validations can also be assigned.

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

### Scope Filters

For scopes that do not take arguments, the filter should provide a boolean that indicates whether or not the scope should be invoked. For example, imagine a scope called `high_priority` with criteria that identifies high priority records. The scope would be invoked by the query parameters `high_priority=true`.

Passing `high_priority=false` will not invoke the scope. This makes it easy to include a filter with a check box UI.

Scopes that do take arguments [must be written as class methods, not inline scopes.](https://guides.rubyonrails.org/active_record_querying.html#passing-in-arguments) For example, imagine a scope called `recent` that takes an as of date as an argument. Here is what that might look like:

```ruby
def self.recent(as_of_date)
  where('created_at > ?', as_of_date)
end
```

### Specifying the Model

Rails conventions are used to determine the controller's model. For example, the PhotosController builds a query against the Photo model. If a controller is namespaced, the model will first be looked up without the namespace, then with the namespace. 

**If the conventions do not provide the correct model**, the model can be named explicitly with the following:

```ruby
filter_model 'Picture'
```


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
    render json: @widgets
  end
end
```

This method optionally takes a starting query. If there was a controller for Active Widgets that should only return active widgets, the following could be passed into the method as the starting point:

```ruby
  def index
    @widgets = build_query_from_filters(Widget.where(active: true))
  end
```

Note that the starting query provides the model, so the model is not looked up and any `model_name` declaration is ignored.

### Query Parameters

The query parameters are pulled from the controller parameters, nested under the key `filter`. For example a request for large, blue widgets might have the following url:

`/widgets?filter[size]=large&filter[color]=blue`

To change the source of the query parameters, override the `filter_parameters` method. Here is another way to provide a default filter:

```ruby
def filter_parameters
  super.with_defaults(active: true)
end
```

This also provides an easy way to nest the criteria under a key other than `filter`:

```ruby
def filter_parameters
  params.to_unsafe_h.fetch(:criteria, {})
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

## Forms and Query Parameters

The controller mixin will look for filter parameters nested under the `filter` key. For example, here's what the query parameters might look like for size and color:

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


## Running Tests

Tests are written in RSpec and the dummy app uses a docker database. The script `bin/start_db.sh` starts and prepares the test
database. It is a one-time step before running the tests.

```bash
bin/start_db.rb
bundle exec rspec
```

The tests can also be run across all the ruby and Rails combinations using appraisal. The install is also a one-time step.

```bash
bundle exec appraisal install
bundle exec appraisal rspec
```

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
