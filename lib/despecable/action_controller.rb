module Despecable
  module ActionController
    def despec(strict: false, &blk)
      despecable_params = params.deep_dup
      @despecable_me ||= despecable_me(params)
      @despecable_me.doit(strict: strict, &blk)
    end

    def despec!(strict: false, &blk)
      despecable_params = params
      @despecable_me ||= despecable_me(params)
      @despecable_me.doit(strict: strict, &blk)
    end

    def despecable_me(params)
      Despecable::Me.new(params, request.query_parameters.merge(request.request_parameters))
    end
  end
end
