module Despecable
  module Spectre
    extend self

    # Create a new class that mimics a controller class, but just
    # documents the action instead of doing anything.
    def new(klass)
      spectre = Class.new(klass)
      spectre.instance_methods.each do |method|
        shadow(spectre, method)
      end
      spectre.prepend(Despecable::Spectral)
      return spectre
    end

    def shadow(spectre, method)
      spectre.send(:define_method, method) do |*args|
        begin
          super(*args)
        rescue
          # spooky
        end
      end
    end
  end
end
