module Despecable
  module ActionController
    def despec(&blk)
      spectator = Despecable::Spectator.new(params.deep_dup)
      spectator.instance_eval(&blk)
      return spectator.params
    end

    def dspec!(&blk)
      spectator = Despecable::Spectator.new(params)
      spectator.instance_eval(&blk)
      return spectator.params      
    end
  end
end
