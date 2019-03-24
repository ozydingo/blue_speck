module Despecable
  module ActionController
    def despec(*args, strict: false, &blk)
      output_params = params.dup
      parsed = despecable_me(output_params).doit(*args, strict: strict, &blk)
      parsed.each do |key, val|
        output_params[key] = val
      end
      return output_params
    end

    def despec!(*args, strict: false, &blk)
      parsed = despecable_me(params).doit(*args, strict: strict, &blk)
      parsed.each do |key, val|
        params[key] = val
      end
      return params
    end

    def despecable_me(params = {})
      supplied_params = request.query_parameters.dup
      # Loop in place of merge due to unpermitted params restriction
      request.request_parameters.each do |key, val|
        supplied_params[key] = val
      end
      @despecable_me ||= Despecable::Me.new(params, supplied_params)
    end
  end
end
