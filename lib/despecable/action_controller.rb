module Despecable
  module ActionController
    def despec(*args, strict: false, &blk)
      despecable_me(params.dup).doit(*args, strict: strict, &blk)
    end

    def despec!(*args, &blk)
      despec(*args, &blk)
      # Loop in place of merge due to unpermitted params restriction
      despecable_me.params.each do |key, val|
        params[key] = val
      end
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
