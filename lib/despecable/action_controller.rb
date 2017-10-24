module Despecable
  module ActionController
    extend ActiveSupport::Concern

    included do
      before_filter :despecify
    end

    def despec(*args, strict: false, &blk)
      despecable_me(params.deep_dup).doit(*args, strict: strict, &blk)
    end

    def despec!(*args, &blk)
      despec(*args, &blk)
      params.merge!(despecable_me.params)
    end

    def despecify
      if !self.class.despec_module.nil? && self.class.despec_module.despec?(params[:action].to_s)
        despec!(&self.class.despec_module.get_despec(params[:action]))
      end
    end

    def despecable_me(params = {})
      @despecable_me ||= Despecable::Me.new(params, request.query_parameters.merge(request.request_parameters))
    end

    module ClassMethods
      def despec_module
        return @despec_module if defined? @despec_module
        if despec_module_defined?
          @despec_module = Despecables.const_get(self.name, false)
          raise TypeError, "#{@despec_module} is not a Despecable::Spectrum" if !(@despec_module < (Despecable::Spectrum))
        else
          @depsec_module = nil
        end
        return @despec_module
      end

      def despec_module_defined?
        if Rails.env.eager_load?
          Despecables.const_defined?(self.name, false)
        else
          begin
            !!Despecables.const_get(self.name, false)
          rescue NameError
            false
          end
        end
      end
    end
  end
end
