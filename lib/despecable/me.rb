module Despecable
  class Me
    attr_reader :params

    # supplied_params are the params that were actually passed in by the user.
    # In Rails, params has some additional keys (e.g. controller, action), so you can
    # pass in request.query_parameters (GET) and/or request.request_parameters (POST)
    # for supplied_params to correctly get only the user-supplied parameters.
    def initialize(params, supplied_params = nil)
      @supplied_params = (supplied_params || params).dup
      @params = params
      @specd = []
    end

    def doit(*args, strict: false, &blk)
      spectator = Despecable::Spectator.new(@params)
      spectator.instance_exec(*args, &blk) unless blk.nil?
      @specd += spectator.specd
      despecably_strict if strict
      return spectator.params
    end

    def unspecd
      @supplied_params.keys.map(&:to_s) - @specd.map(&:to_s)
    end

    def despecably_strict
      if !unspecd.empty?
        list = unspecd.map{|x| "'#{x}'"}.join(", ")
        error = Despecable::UnrecognizedParameterError.new("Unrecognized parameters supplied: #{list}", parameters: unspecd)
        raise error
      end
    end
  end
end
