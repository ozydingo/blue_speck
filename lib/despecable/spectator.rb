module Despecable
  class Spectator < BasicObject
    attr_reader :params

    def initialize(params)
      @params = params
      @spectacles = ::Despecable::Spectacles.new
    end

    def integer(name, options = {})
      _spec(name, :integer, options)
    end

    def string(name, options = {})
      _spec(name, :string, options)
    end

    def boolean(name, options = {})
      _spec(name, :boolean, options)
    end

    def date(name, options = {})
      _spec(name, :date, options)
    end

    def datetime(name, options = {})
      _spec(name, :datetime, options)
    end

    private

    def _spec(name, type, options = {})
      if params.key?(name)
        params[name] = @spectacles.public_send(type, name)
      elsif options.key?(:default)
        params[name] = options[:default]
      end
      @spectacles.validate_param(name, options)
      return params[name]
    rescue ::Despecable::DespecableError
      ::Kernel.raise $!.insert_name_here(name)
    end

  end
end
