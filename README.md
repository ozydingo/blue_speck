# despecable
Easy self-documenting parameter specifications for Rails API routes

Keeping API docs in sync with the code is a pain. It's nasty. Odious. It's ...

... despecable.

So let's make it easy!

## What's new (just the highlights)
### v 0.2.0
Allow case, length options for String params
### v 0.1.0
Added basic rspec test suite!
### v 0.0.0
A gem was born.

## Basic Usage

### Parameter Specification

The first thing any developer wants to know about you api are: what are the endpoints (routes) and what are the parameter requirements for each. Despecable was born out of a desire to standardize this layer of API writing.

<a id='example1' name='example1'></a>
```ruby
class WidgetsController < ApplicationController
  include Despecable::ActionConntroller

  def index
    despec!(strict: true) do
      string :api_key, required: true
      integer :id, in: 1..999_999_999, array: true
      string :name, length: 1..100
      string :function, in: ["foo", "bar"], case: false
      datetime :created_after
      boolean :active
      boolean :show_secret, default: false
    end

    project = Project.find_by(api_key: api_key)
    widgets = project.widghets.search(create_filters(params))
  end
end
```

"Woah", you say, "you've just added 9 lines of code to a 2-line method!". You're damn right I did. You have to write your API docs anyway. Why not write it in the method itself, so you get functional docs, instead of keeping a separate text file with your documentation that you have to keep in sync?

What functionality is that? I'm glad you asked!

First, let me note that `despec!` modifies the `params` hash in place. This is my typical use case: just get the params into the format I want them. Use `despec` (without the bang) if you do not want this behavior: it will `deep_dup` the params hash first.

### Parameter Coercion

The first thing you notice with the above block is we have a few obvious type declarations. `:api_key` will be read as a `String`, `id` as an `Integer`, and so on. Currently, `Despecable` supports:

- `string`
- `integer`
- `float`
- `boolean`
- `datetime`
- `date`
- `file`
- `any`

Each of these comes with its own parsing method. Custom parsing (e.g. for `:datetime`) is in the works, but for now feel free to monkey patch the `datetime` method in the `Despecable::Spectacle` class. See the [Monkey Patching](#monkey-patching) section, below, for more details.

You can provide a `default` value to any of these methods. *YOUR DEFAULT VALUE IS NOT VALIDATED!* This will take effect if the parameter is not found. If `default` is not provided, then `nil` will be returned for any parameter not supplied in the call.

If the parameter supplied cannot be coerced into the desired format, `Despecable` will raise a `Despecable::InvalidParamter` error with a useful message that you can safely pass directly to the client along with your favorite 400's status code. For example:

> Invalid value for param: 'active'. Require type: boolean (1/0 or true/false)

### Parameter Validation

#### Presence

Next, you might notice the first `required: true` attached to the `string :api_key` spec. This simply checks for the presnces of the `api_key` param, and will raise a `Despecable::MissingParameterError` if absent.

#### Value

You should see the `string :function, in: ["foo", "bar"]`. This will check that the coerced param is contained within the set (`Array` or `Range`) specified. If not, it will raise a `Despecable::IncorrectParameterError`

#### String Options

Lastly, you can see the `case: false, length: 1..100` options on some of the string parameters. The `case` option is to allow case-insensitive matching if you are validating param values using `in`. the `length` options is a number, array, or range that will raise a `Despecable::IncorrectParameterError` if the parameter is present and not in the allowed lengths.

#### Arrayification

Even more lastly, you'll notice the `array: true` option on the `id` param. This option tells `Despecable` that the specified param will be interpreted as an array: either a comma-separated string (`x=1,2`) or a legit Array (using Rails `x[]=1&x[]=2` param string syntax). In the former case, `Despicable` will convert the parameter value into an Array by spliting on "," (note: this can result in a one-element array) and validate each value against the other options for that parameter spec.

An alternative keyword, `arrayable`, will only split if commas are present. This keyword is (yes, already) deprecated in favor of the more consistent behavior of `array`.

### Despecable Errors

The coolest thing about using `Despecable` is that it makes it so easy to generate helpful and cosistent messaging to your API's users about what they're not doing with with your API. So far, we've only talked about spec violations raising errors. But you want the user to see these messages, not for some internal server error to bring the request crashing into a million pieces. I suggest implementing this functionality something like so:

```ruby
class WidgetsController < ActionController::Base
  rescue_from Despecable::DespecableError, with: :parameter_error

  private

  def parameter_error(exception)
    render json: {error: exception.message, items: exception.parameters}, status: 400
  end
end
```

You can, of course, use different methods for each of the different types of error, but I see little reason to do so. If you disagree, the error types are:
- `Despecable::InvalidParameterError`
- `Despecable::IncorrectParameterError`
- `Despecable::MissingParameterError`
- `Despecable::UnrecognizedParameterError`

Notice also that we have called `exception.parameters`. This is a unique little feature of `Despecable::DespecableError` that will store for you the names of the parameters in violation. This is particularly useful if you want to extract ore display the errors in a more machine-readable format.

### Despecable Controllers

I've given the example above about including `Despecable::ActionController` in `WidgetsController`. A likely preferred pattern is to include this module in a base API controller from which all other API controller inherit. This might then look like:

```
class ApiController < ActionController::Base
  include Despecable::ActionController
end

class WidgetsController < ApiController
  # ...
end
```

## Advanced Usage

### Strict Mode

An optional flavor of `Despecable` is "strict mode", where the API will complain about extra parameters not recognized by the route. Most APIs simply ignore these extra parmaeters. I don't like this because it's easy to make a small typo in a parameter name, and the developer is left guessing as to why they are not getting the desired functionality.

Enable strict mode by passing the keyword arg `strict: true` to the `despec` block, as in the first [examnple above](#example1). Any parameters not yet specified in an evaluated `despec` block will be listed in a `Despecable::UnrecognizedParameterError`.

Here's the cooler part: you can use multiple `despec` blocks, and `Despecable` will remember all of the parameters encountered in a given action. So if you have a `before_filter` that looks for some parameter -- say, `api_key`, just add a `despec` block for that parameter in your before_filter and it will be allowed in the strict block.

Here's an example of what that might look like:

```ruby
class ApiController < ActionController::Base
  before_filter :get_api_key

  def get_api_key
    despec! do
      string :api_keuy
    end
    @api_key = ApiKey.find_by(key: params[:api_key]) or raise ApiError, "Invalid API Key"
  end
end

class WidgetsController < ApiControler
  def show
    despec!(strict: true) do
      integer :id, required: true
    end
  end
end
```

Note that `strict` is not set to `true` in the before_filter, otherwise it would immediately complain about any parameters other than `api_key`!

If you have an action with no (additional) parameters but wish to use strict mode, simply don't pass a block:

`despec!(struct: true)`

### Dynamic specs

The code inside a `despec` block does not have access to your controller methods or variables. To pass in custom or dynamic values into a `despec` block, pass them in as argument to the block. For example, let's say you have a `format` parameter whose allowed values are dynamic (e.g. based on the user, etc). Here we assume you have defined a method or variable `formats` that contains or computes the array of allowed values. Use it thusly:

```ruby
despec!(formats, strict: true) do |allowed_formats|
  string :format, in: allowed_formats
end
```

<a id='monkey-patching' name='monkey-patching'></a>
### Monkey Patching

The root of the magic happens in a `Despecable::Spectator`. This `BasicObject` subclass is responsible for interpreting the block you pass to the `despec` method. It dons a pair of `Despecable::Spectacles` to help it read and verify the parameters. So if you want to modify the parsing of `DateTime` from the default `rfc3999` parsing to use, for example, the [Chronic](https://github.com/mojombo/chronic) gem, you can monkey-patch:

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
