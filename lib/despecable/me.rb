module Despecable
  class Me
    attr_reader :params

    def initialize(params)
      @params = params
      @specd = []
    end

    def doit(*args, &blk)
      spectator = Despecable::Spectator.new(@params)
      spectator.instance_exec(*args, &blk) unless blk.nil?
      @specd += spectator.specd
      return spectator.params
    end

    def strict(user_params)
      unspecd = user_params.map(&:to_s).uniq - @specd.map(&:to_s)
      if !unspecd.empty?
        list = unspecd.map{|x| "'#{x}'"}.join(", ")
        raise Despecable::UnrecognizedParameterError.new(
          "Unrecognized parameters supplied: #{list}",
          parameters: unspecd
        )
      end
    end
  end
end
