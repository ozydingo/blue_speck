module Despecable
  module ActionController
    extend ActiveSupport::Concern

    included do
      class_attribute :despecable_macros
      self.despecable_macros = {}
      class_attribute :despecable_fragments
      self.despecable_fragments = {}
    end

    module ClassMethods
      def despecable_macro(name, &blk)
        despecable_macros.merge!(name: blk)
      end

      def despecable_fragment(name, options)
        despecable_fragments.merge!(name: options)
      end
    end

    def despec(*args, strict: false, &blk)
      despecable_me(params.deep_dup).doit(*args, strict: strict, &blk)
    end

    def despec!(*args, &blk)
      despec(*args, &blk)
      params.merge!(despecable_me.params)
    end

    def despecable_me(params = {})
      @despecable_me ||= Despecable::Me.new(params, request.query_parameters.merge(request.request_parameters))
      despecable_macros.each{|name, macro| @despecable_me.add_macro(macro)}
      despecable_fragments.each{|name, fragment| @despecable_me.add_fragment(fragment)}
      return @despecable_me
    end
  end
end
