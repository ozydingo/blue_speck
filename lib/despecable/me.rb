module Despecable
  class Me
    attr_reader :params

    # supplied_params are the params that were actually passed in by the user.
    # In Rails, params has some additional keys (e.g. controller, action), so you can
    # pass in request.query_parameters (GET) and/or request.request_parameters (POST)
    # for supplied_params to correctly get only the user-supplied parameters.
    def initialize(params, supplied_params = nil)
      @supplied_params = (supplied_params || params).deep_dup
      @params = params
      @spectator = Despecable::Spectator.new(@params)
    end

    def doit(strict: false, &blk)
      @spectator.instance_eval(&blk) unless blk.nil?
      despecably_strict if strict
      return @spectator.params
    end

    def specd
      @spectator.specd.map(&:to_s)
    end

    def unspecd
      @supplied_params.keys.map(&:to_s) - specd
    end

    def despecably_strict
      if !unspecd.empty?
        list = unspecd.map{|x| "'#{x}'"}.join(", ")
        raise Despecable::UnrecognizedParameterError, "Unrecognized parameters: #{list}"
      end
    end
  end
end
