module Despecable
  class Spectator < BasicObject
    # This class is used to read (eval) the despec block
    # Any methods in that block must be defined here, and this object
    # must be stateful to be read by the controller

    attr_reader :params, :specd

    def initialize(params)
      @input_params = params
      # TODO: allow this to be the same object to save copies
      @params = {}
      @spectacles = ::Despecable::Spectacles.new
      @specd = []
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

    def float(name, options = {})
      _spec(name, :float, options)
    end

    def file(name, options = {})
      _spec(name, :file, options)
    end

    def any(name, options = {})
      _spec(name, :any, options)
    end

    def custom(name, options = {}, &blk)
      _spec(name, :custom, options, &blk)
    end

    private

    def _spec(name, type, options = {}, &blk)
      @specd << (name)
      if !@input_params.key?(name) && options.key?(:default)
        @params[name] = options[:default]
      elsif !@input_params.key?(name) && options.key?(:required)
        ::Kernel.raise ::Despecable::MissingParameterError.new("Missing required parameter: '#{name}'", parameters: name)
      elsif !@input_params.key?(name)
        return
      elsif options[:array]
        values = @spectacles.arrayify(@input_params[name])
        @params[name] = values.map{|val| @spectacles.read(name, val, type, options, &blk)}
      elsif options[:arrayable] && @spectacles.arrayable?(@input_params[name])
        # TODO: deprecate arrayable in favor of array
        values = @spectacles.arrayify(@input_params[name])
        @params[name] = values.map{|val| @spectacles.read(name, val, type, options, &blk)}
      else
        @params[name] = @spectacles.read(name, @input_params[name], type, options, &blk)
      end
    end
  end
end
