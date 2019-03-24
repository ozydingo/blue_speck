module Despecable
  module ActionController
    def despec(*args, strict: false, &blk)
      output_params = params.dup
      parsed = despecable_me(output_params).doit(*args, &blk)
      despecable_me.strict(request.query_parameters.keys + request.request_parameters.keys) if strict
      parsed.each do |key, val|
        output_params[key] = val
      end
      return output_params
    end

    def despec!(*args, strict: false, &blk)
      parsed = despecable_me(params).doit(*args, &blk)
      despecable_me.strict(request.query_parameters.keys + request.request_parameters.keys) if strict
      parsed.each do |key, val|
        params[key] = val
      end
      return params
    end

    # A cached instance of Despecable::Me will keep track of all despec calls
    # in a given request / action. This allows despec to be called multiple
    # times (e.g. in before_actions) and keep track of all spec'd params
    def despecable_me(params = {})
      @despecable_me ||= Despecable::Me.new(params)
    end
  end
end
