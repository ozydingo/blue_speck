module Despecable
  module ActionController
    def despec(*args, strict: false, &blk)
      despecable_me(params.deep_dup).doit(*args, strict: strict, &blk)
    end

    def despec!(*args, &blk)
      despec(*args, &blk)
      params.merge!(despecable_me.params)
    end

    def despecable_me(params = {})
      @despecable_me ||= Despecable::Me.new(params, request.query_parameters.merge(request.request_parameters))
    end
  end
end
