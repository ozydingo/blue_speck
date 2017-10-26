module Despecable
  class Spectrum
    @despecs = {}

    def self.inherited(child)
      child.initialize_despecs
    end

    class << self
      def action(name, description = nil, &blk)
        @despecs[name.to_s] = {desc: description, despec: blk}
      end

      def get_despec(action)
        @despecs[action.to_s] && @despecs[action.to_s][:despec]
      end

      def get_description(action)
        @despecs[action.to_s] && @despecs[action.to_s][:description]
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
