module Despecable
  module ActionController
    def despec(strict: false, &blk)
      me = Despecable::Me.new(params.deep_dup)
      me.doit(&blk)
      despecabled.concat(me.specd)
      despecably_strict if strict
    end

    def despec!(strict: false, &blk)
      me = Despecable::Me.new(params)
      me.doit(&blk)
      despecabled.concat(me.specd)
      despecably_strict if strict
    end

    def despecabled
      @despecabled ||= []
    end

    def despecably_strict
      unused = request.query_parameters.keys.map(&:to_s) - despecabled.map(&:to_s)
      if !unused.empty?
        list = unused.map{|x| "'#{x}'"}.join(", ")
        raise Despecable::UnrecognizedParameterError, "Unrecognized parameters: #{list}"
      end
    end
  end
end
