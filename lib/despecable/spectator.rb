module Despecable
  class Spectator < BasicObject
    attr_reader :params

    def initialize(params)
      @params = params
      @spectacles = ::Despecable::Spectacles.new(params)
    end

    def integer(name, options = {})
      params[name] = @spectacles.integer(name) if params.key?(name)
      @spectacles.validate_param(name, options)
      return params[name]
    end

    def string(name, options = {})
      params[name] = @spectacles.string(name) if params.key?(name)
      @spectacles.validate_param(name, options)
      return params[name]
    end

    def boolean(name, options = {})
      params[name] = @spectacles.boolean(name) if params.key?(name)
      @spectacles.validate_param(name, options)
      return params[name]
    end

    def date(name, options = {})
      params[name] = @spectacles.date(name) if params.key?(name)
      @spectacles.validate_param(name, options)
      return params[name]
    end

    def datetime(name, options = {})
      params[name] = @spectacles.datetime(name) if params.key?(name)
      @spectacles.validate_param(name, options)
      return params[name]
    end
  end
end
