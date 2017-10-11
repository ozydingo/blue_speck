module Despecable
  class Me
    attr_reader :params, :spectator

    def initialize(params)
      @params = params
      @spectator = Despecable::Spectator.new(@params)
    end

    def doit(&blk)
      @spectator.instance_eval(&blk)
      return @spectator.params
    end

    def specd
      @spectator.specd
    end
  end
end
