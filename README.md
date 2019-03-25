# despecable
Clear & easy parameter specification for Rails controllers & APIs.

Despecable allows you to easily declare your parameter types, allowed values, default values, and other requirements and automatically get parameter parsing and clean error handling. This is probably most useful for controllers responding to external API calls, but nothing's stopping you from using it to parse params from your own forms or links either. <!--Nothing except MY PIRANHA GUN!-->

## Example

Do this:

```ruby
class EvilPlansController < ApplicationController
  include Despecable::ActionController

  def steal_the_moon
    despec! do
      datetime :when,       require: true
      integer  :minions,    in: 0..500, default: 0
      string   :weapons,    in: ["freeze_ray", "squid_launcher", "fart_gun"], array: true
      boolean  :recital     default: false
    end

    # ...
  end
end
```

Request this:

`...evil_plans/steal_the_moon?when=2019-03-24T21:33:33-04:00&minions=172&weapons=freeze_ray,fart_gun`

Get this:

```
#> params

{"when"=>#<DateTime: 2019-03-24T21:33:33-04:00 ((2458568j,5613s,921152000n),-14400s,2299161j)>,
 "minions"=>172,
 "weapons"=>["freeze_ray", "fart_gun"],
 "recital"=>false}
```

## Why?

* Self-document what you expect parameters to be for a given action. This is especially useful for API controllers.
* Get in front of incorrect parameters with easy to understand messaging before any other code in the action is executed.
* Convert params into their expected types
* Specify required params
* Complain about unrecognized params (optional)
* Give default values
* Validate allowable values
* Easily generate documentation for your API endpoints

## What's new (just the highlights)
### v 1.0.0
* Rails 5 support!
* Custom parsers.
* Better testing and documentation.

## Basic Usage

Add `despecable` to your Gemfile, or `gem install despecable`.

The basic anatomy of using Despecable is to call `despec` (non-destructive) or `despec!` (destructive / in-place) in your controller action, preferably at or near the top, with a block containing param specs:

```ruby
despec! do
  [type] [param_name] [options, ...]
end
```

For example:

```ruby
despec! do
  string   :name,       required: true
  string   :gender,     in: ["female", "male", "other", "unspecified"]
  datetime :birthday
  float    :numbers,    array: true
  boolean  :send_email, default: false
end
```

(Note: using `despec!` instead of `despec` to modify params in place performs only a `dup`, not a `deep_dup`, so be careful with in-place modification of param values!)

### Types

Declare parameter types to have Despecable validate and convert the parameter values for you. Supported types are:

- `string`
- `integer`
- `float`
- `boolean`
- `datetime` (RFC3339 format)
- `date` (RFC3339 format)
- `file` (form upload)
- `any`
- `custom`

### Options

Supported options include:

- `:required` (boolean, default `false`) - If true, raise an error if a parameter was not present in the request.
- `:default` (value) - If parameter is not present in the request, use this default value
- `:array` (boolean, default `false`) - Convert the param into an array from either a comma-separated string or Rails parameter array
- `:in` (Array or Range) - Raise an error if a value is not in the supplied array or range
- `:case` (boolean; default `true`) - String param type only. Ignore case when matching param value to `:in` spec.
- `:length` (Integer or Array/Range) - String param type only. Raise an error if param value is not within specified length

### Syntax examples

```ruby
integer :id,      required: true
string  :type,    default: "evil"
float   :alpha,   in: 0..1
string  :color,   in: ["red", "green", "blue"]
string  :token,   length: 16
string  :tag,     length: 4..32
string  :drink,   in: ["Coffee", "Tea"], case: false
float   :ratings, in: 0..5, array: true
custom( :birthday, default: Date.today ) do
  Date.parse(value)
end
```

The parentheses in the last example are not strictly necessary but relieve much confusion.

### Errors

Errors that result from bad parameter values will throw one of the following subtypes of `Descpable::DespecableError`:

- `Despecable::InvalidParamterError`: value could not be converted into specified type
- `Despecable::IncorrectParameterError`: value was outside of allowed range
- `Despecable::MissingParameterError`: value was required but not provided
- `Despecable::UnrecognizedParameterError`: strict mode was enabled and a parameter not in the spec was provided

The error message will be a safe, informative message you can pass directly back to the client along with your favorite 400s status code. The error will also have an extra field, `parameters`, that contains the parameter names in violation. If you're writing a json API, for example, you can easily standardize your error responses like this, using `ActionController`'s `rescue_from` method:

```ruby
class WidgetsController < ActionController::Base
  rescue_from Despecable::DespecableError, with: :parameter_error

  private

  def parameter_error(exception)
    render json: {error: exception.message, items: exception.parameters}, status: 400
  end
end
```

An example error response:

```
{
  error: "Invalid value for param: 'active'. Require type: boolean (1/0 or true/false)",
  items: ["param1"]
}
```

## Advanced Usage

### Strict Mode

To raise `Despecable::UnrecognizedParameterError` if any parameters are supplied that are *not* specified, add `strict: true` to the `despec` method call:

```ruby
despec!(strict: true) do
  #...
end
```

This is particularly useful for debugging API call issues such as mistyped parameter names.

Despecable supports calling despec as many times as you want. So if you have a parent class controller or `before_action` that you want to add a parameter validation to, you can! Just save `strict` mode to the last call, of course.

```ruby
class ApiController < ActionController::Base
  before_action :get_api_key

  def get_api_key
    # Don't use strict: true here or no other params will be allowed!!
    despec! do
      string :api_keuy
    end
    @api_key = ApiKey.find_by(key: params[:api_key]) or raise ApiError, "Invalid API Key"
  end
end

class WidgetsController < ApiControler
  def show
    # strict: true is used on the final param-parsing block of any action
    despec!(strict: true) do
      integer :id, required: true
    end
  end
end
```

If you have no additional parameters for a specific action other than the ones from the parent controller or `before_action`, simple pass `despec` an empty block:

```ruby
# No additional parameters.
depsec(strict: true) {}
```

### Custom types

If the standard set of type parsers aren't good enough for ya, you can use `custom` with a provided block. The block should take arguments: `name, value, options`, where `name` is the name of the parameter, `value` is the value straight out of the `params` object, and `options` is a Hash that contains the above options such as `in:`, `array:`, etc. You can use any of these options, of course, but the standard options are still parsed by Despecable so you don't have to worry about reimplementing any of those features.

```ruby
custom(:doubled) do |name, value, options|
  value.to_i * 2
end
```

### Dynamic specs

The code inside a `despec` block does not have access to your controller methods or variables. What, you think this is Javascript? No, to use additional information, pass it in as an argument to `despec` that will be passed to the block:

```ruby
formats = ['mp3', 'ogg', 'm4a']
despec!(formats, strict: true) do |fmt|
  string :format, in: fmt
end
```

### Monkey Patching

Happy to have you hacking. The root of the magic happens in a `Despecable::Spectator`. This `BasicObject` subclass is responsible for evaluating the block you pass to the `despec` method. It dons a pair of `Despecable::Spectacles` to help it read and verify the parameters. So if you want to modify the parsing of `DateTime` from the default `rfc3999` parsing to use, for example, the [Chronic](https://github.com/mojombo/chronic) gem, you can monkey-patch:

```ruby
class Despecable::Spectacle
  def datetime(value)
    Chronic.parse(value) or raise Despecable::InvalidParameterError, "Required: date string (e.g. 'tomorrow' or '2017-01-01')"
  end
end
```

Note that these methods on `Spectacle` do not get called if the param is not present, so you don't have to worry about handling the `nil` case.

### Human Patching

If you have more legit contributions to make to `Despecable`, submit a PR! Please keep your commits clean and rebased off of the current master branch, and message your commits with `type(concern) [initials] message`; e.g. `feat(Chronic) [AS] Add Chronic parsing as a datetime option`. `type` can be `feat`, `fix`, `refactor`, `doc`, or get creative.
