module Despecable
  class Specialist
    def initialize(klass)
      @klass = klass
      @spectral = Despecable::Spectre.new(klass)
    end

    def spec(action)
      spectre = @spectral.new
      spectre.send(action)
      return spectre.despecabled
    end
  end
end
