# despecable
Easy self-documenting parameter specifications for Rails API routes

Keeping API docs in sync with the code is a pain. It's nasty. Odious. It's ...

... despecable.

So let's make it easy!

## Parameter Specificaion

The first thing any developer wants to know about you api are: what are the endpoints (routes) and what are the parameter requirements for each. Despecable was born out of a desire to standardize this layer of API writing.

```ruby
class WidgetsController < ApplicationController
  include Despecable::ActionConntroller

  def index
    despec! do
      string :api_key, required: true
      integer :id, in: 1..999_999_999, arrayable: true
      string :name
      string :function, in: ["foo", "bar"]
      datetime :created_after
      boolean :active
      boolean :show_secret, default: false
    end

    project = Project.find_by(api_key: api_key)
    widgets = project.widghets.search(create_filters(params))
  end
end
```

"Woah", you say, "you've just added 9 lines of code to a 2-line method!". You're damn right I did. You have to write your API docs anyway. Why not write it in the method itself, so you get functional docs, instead of keeping a separate text file with your documnetation that you have to keep in sync?

What functionality is that? I'm glad you asked!

First, let me note that `despec!` modifies the `params` hash in place. This is my typical use case: just get the params into the format I want them. Use `despec` (without the bang) if you do not want this behavior: it will `deep_dup` the params hash first.

## Parameter Coercion

The first thing you notive with the above block is we have a few obious type declaraions. `:api_key` will be read as a `String`, `id` as an `Integer`, and so on. Currently, `Despecable` supports:

- `string`
- `integer`
- `boolean`
- `datetime`
- `date`

Each of these comes with its own parsing method. Custom parsing (e.g. for `:datetime`) is in the works, but for now feel free to monkey patch the `datetime` method in the `Despecable::Spectacle` class. See the [Monkey Patching](#monkey-patching) section, below, for more details.

You can provide a `default` value to any of these methods. *YOUR DEFAULT VALUE IS NOT VALIDATED!* This will take effect if the parameter is not found. If `default` is not provded, then `nil` will be returned for any parameter not supplied in the call.

If the parameter supplied cannot be coerced into the desired format, `Despecable` will raise a `Despecable::InvalidParamter` error with a useful message that you can safely pass directly to the client along with your favorite 400's status code. For example:

> Invalid value for param: 'active'. Require type: boolean (1/0 or true/false)

## Parameter Verification

### Parameter Presence

Next, you might notice the first `required: true` attached to the `string :api_key` spec. This simply checks for the presnces of the `api_key` param, and will raise a `Despecable::MissingParameterError` if absent.

### Parameter Verification

Lastly, you should see the `string :function, in: ["foo", "bar"]`. This will check that the coerced param is contained within the set (`Array` or `Range`) specified. If not, it will raise a `Despecable::IncorrectParameterError`

### Parameter Arrayification

Even more lastly, you'll notive the `arrayify: true` option on the `id` param. This option tells `Despecable` that the specified param can be received as an array: either a comma-separated string (`x=1,2`) or a legit Array (using Rails `x[]=1&x[]=2` param string syntax). If either of these conditions are detected, `Despicable` will convert the parameter value into an Array and validate each value against the other options for that parameter spec.

## Despecable Errors

By now, you may have noticed that our mode of operation is to raise errors when a parameter doesn't meet the spec. But you want the user to see these messages, not for some internal server error to bring the request crashing into a million pieces. I suggest implmeneting this functionality something like so:

```ruby
class WidgetsController < ActionController::Base
  rescue_from Despecable::InvalidParameterError, with: :bad_request
  rescue_from Despecable::IncorrectParameterError, with: :bad_request
  rescue_from Despecable::MissingParameterError, with: :bad_request

  def bad_request(exception)
    render json: {error: exception.message}, status: 400
  end
end
```

You can, of course, use different methods for each, but I see little reason to do so.

## Despecable Controllers

I've given the example above about including `Despecable::ActionController` in `WidgetsController`. A likely preferred pattern is to include this module in a base API controller from which all other API controller inherit. This might then look like:

```
class ApiController < ActionController::Base
  include Despecable::ActionController
end

class WidgetsController < ApiController
  # ...
end
```

<a href='monkey-patching'></a>
## Monkey Patching

The root of the magic happens in a `Despecable::Spectator`. This `BasicObject` subclass is responsible for interpreting the block you pass to the `despec` method. It dons a pair of `Despecable::Spectacles` to help it read and verify the parameters. So if you want to modify the parsing of `DateTime` from the default `rfc3999` parsing to use, for example, the [Chronic](https://github.com/mojombo/chronic) gem, you can monkey-patch:

```ruby
class Despecable::Spectacle
  def datetime(value)
    Chronic.parse(value) or raise Despecable::InvalidParameterError, "Required: date string (e.g. 'tomorrow' or '2017-01-01')"
  end
end
```

Note that these methods on `Spectacle` do not get called if the param is not present, so you don't have to worry about handling the `nil` case.

## Human Patching

If you have more legit contributions to make to `Despecable`, submit a PR! Please keep your commits clean and rebased off of the current master branch, and message your commits with `type(concern) [initials] message`; e.g. `feat(Chronic) [AS] Add Chronic parsing as a datetime option`. `type` can be `feat`, `fix`, `refactor`, `doc`, or get creative.
