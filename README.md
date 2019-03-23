# despecable
Parameter typing, validation, and self-documentation for Rails controllers.

Do this:

```ruby
class MyController < ApplicationController
  include Despecable::ActionController

  def my_action
    despec! do
      string   :name,       required: true
      string   :gender,     in: ["female", "male", "other", "unspecified"]
      integer  :age,        in: 1..1000
      datetime :birthday
      float    :numbers,    array: true
      boolean  :send_email, default: false
    end

    # ...
  end
end
```

Get this:

```
{"name"=>"wonk",
 "age"=>132,
 "birthday"=>#<Date: 2019-03-23 ((2458566j,0s,0n),+0s,2299161j)>,
 "numbers"=>[2.72, 3.14],
 "send_email"=>true}
```

## What's new (just the highlights)
### v 0.3.0
Update for Rail 5, which was barfing on `ActionController::Parameters#merge`

## Basic Usage

Add `despecable` to your Gemfile, or `gem install despecable`.

Despecable makes it easy to document, parse, and validate your controller params in a simple block of code. Why?

* Self-document what you expect parameters to be for a given action. This is especially useful for API controllers.
* Get in front of incorrect parameters with easy to understand messaging before any other code in the action is executed.
* Convert params into their expected types
* Specify required params
* Complain about unrecognized params (optional)
* Give default values
* Validate allowable values
* Easily generate documentation for your API endpoints

(Note: using `despec!` instead of `despec` to modify params in place performs only a `dup`, not a `deep_dup`, so be careful with in-place modification of param values!)

The basic anatomy of using Despecable is to call `despec` or `despec!` in your controller action, preferably at or near the top, with a block containing param specs:

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
  integer  :age,        in: 1..1000
  datetime :birthday
  float    :numbers,    array: true
  boolean  :send_email, default: false
end
```

### Types

Declarations in the above example such as `string` and `integer` are type declarations. These are methods defined by Despecable to convert request parameters. Supported types are:

- `string`
- `integer`
- `float`
- `boolean`
- `datetime`
- `date`
- `file`
- `any`
- `custom`

If a parameter cannot be converted, Despecable will raise a `Despecable::InvalidParamter` error with a useful message that you can safely pass directly to the client along with your favorite status code somewhere in the 400s. For example:

> Invalid value for param: 'active'. Require type: boolean (1/0 or true/false)

### Defaults

Add `default:` to a param spec to specify a default value for that param if it was not given in the request. This value is not validated, so you can use a default value that is not of the same type as your declaration. But why would you do that?

### Validation

#### Required params

Add `required: true` to raise `Despecable::MissingParameterError` if the spec'd param is not supplied in the request.

```ruby
integer :id, required: true
```

#### Allowed values

Add `in: ARRAY` or `in: RANGE` to give allowable values for a param. Violators will encounter a  `Despecable::IncorrectParameterError`

```ruby
float :alpha, in: 0..1
string :color, in: ["red", "green", "blue"]
```

#### String Options

For string params, you can specify case sensitivity and allowable lengths, or else face the wrath of the `Despecable::IncorrectParameterError`

```ruby
string :token, length: 16
string :tag,   length: 4..32
string :drink, in: ["Coffee", "Tea"], case: false
```

#### Arrayification

Rails handles parameter arrayification if you use its form helpers by sending the params like `x[]=1&x[]=2`. Despecable observes this but also allows the param value to be a comma-separated string, such as `x=1,2`. This is much easier for API endpoints, and also can be used to parse single-field form inputs. Nice.

```ruby
float :ratings, in: 0..5, array: true
```

### Despecable Errors

If you're writing an API controller, Depsecable makes it easy to give immediate, informative error messages to your clients based entirely on your parameter specifications. An easy way to do this is to use `ActionController`'s `rescue_from` method:

```ruby
class WidgetsController < ActionController::Base
  rescue_from Despecable::DespecableError, with: :parameter_error

  private

  def parameter_error(exception)
    render json: {error: exception.message, items: exception.parameters}, status: 400
  end
end
```

There are four subtypes of `Despecable::DespecableError`; the parent class is never used directly. These are:

- `Despecable::InvalidParameterError`
- `Despecable::IncorrectParameterError`
- `Despecable::MissingParameterError`
- `Despecable::UnrecognizedParameterError`

You can, of course, use different methods for each of the different types of error, but I see little reason to do so.

You might have noticed an oddity in the example when we called `exception.parameters`. This is a feature of `Despecable::DespecableError` that stores the names of the parameters that caused the violation -- particularly useful if you want to extract ore display the errors in a more machine-readable format.

## Advanced Usage

### Strict Mode

To raise `Despecable::UnrecognizedParameterError` if any parameters are supplied that are *not* specified, add `strict: true` to the `despec` method call:

```ruby
despec(strict: true) do
  #...
end
```

This is particularly useful for debugging API call issues such as mistyped parameter names.

Key, here, is that Despecable supports calling despec as many times as you want. So if you have a parent class controller or `before_action` that you want to add a parameter validation to, you can! Just save `strict` mode to the last call, of course.

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
depsec(strict: true) do
  # No additional parameters.
end
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
