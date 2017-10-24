module Despecable
  class Spectator < BasicObject
    attr_reader :params, :specd

    def initialize(params)
      @params = params
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

    def float
      _spec(name, :datetime, options)
    end

    def file
      _spec(name, :datetime, options)
    end

    def any
      _spec(name, :datetime, options)
    end

    private

    def _spec(name, type, options = {})
      @specd.append(name)
      if !params.key?(name) && options[:default]
        params[name] = options[:default]
      elsif options[:arrayable] && @spectacles.arrayable?(params[name])
        values = @spectacles.arrayify(params[name])
        params[name] = values.map{|val| @spectacles.read(val, type, options)}
      else
        value = @spectacles.read(params[name], type, options)
        params[name] = value if params.key?(name)
      end
    rescue ::Despecable::DespecableError
      ::Kernel.raise $!.insert_name_here(name)
    end
  end
end
