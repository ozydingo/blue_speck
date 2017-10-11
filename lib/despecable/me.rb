module Despecable
  class Me
    attr_reader :params

    def initialize(params)
      @params = params
    end

    def doit(&blk)
      spectator = Despecable::Spectator.new(@params)
      spectator.instance_eval(&blk)
      return spectator.params
    end
  end
end
