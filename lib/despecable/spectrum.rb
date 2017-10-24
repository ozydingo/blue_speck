module Despecable
  class Spectrum
    @despecs = {}

    def self.inherited(child)
      child.initialize_despecs
    end

    class << self
      def action(name, &blk)
        @despecs[name.to_s] = blk
      end

      def get_despec(action)
        @despecs[action.to_s]
      end

      def despec?(action)
        actions.include?(action.to_s)
      end

      def actions
        if self == ::Despecable::Spectrum
          @despecs.keys
        else
          @despecs.keys + superclass.actions
        end
      end

      protected

      def initialize_despecs
        @despecs = {}
      end
    end
  end
end
