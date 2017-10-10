module Despecable
  class Reader < BasicObject
    attr_reader :params

    def initialize(params)
      @params = params
    end

    def integer(name, options = {})
      coerce_integer(name) if params.key?(name)
      validate_param(name, options)
      return params[name]
    end

    def string(name, options = {})
      coerce_string(name) if params.key?(name)
      validate_param(name, options)
      return params[name]
    end

    def boolean(name, options = {})
      coerce_boolean(name) if params.key?(name)
      validate_param(name, options)
      return params[name]
    end

    def date(name, options = {})
      coerce_date(name)
      validate_param(name, options)
      return params[name]
    end

    def datetime(name, options = {})
      coerce_datetime(name)
      validate_param(name, options)
      return params[name]
    end

    private

    def validate_param(name, options)
      validate_param_presence(name) if options[:required]
      validate_param_value(name, options[:in]) if options.key?(:in) && params.key?(name)
    end

    def validate_param_presence(name)
      ::Kernel.raise ::Despecable::MissingParameterError, "Missing required param: '#{name}'" if !params.key?(name)
    end

    def validate_param_value(name, allowed_values)
      ::Kernel.raise ::Despecable::IncorrectParameterError, "Incorrect value for param: '#{name}'" if !allowed_values.include?(params[name])
    end

    def coerce_integer(name)
      int = params[name].to_i
      ::Kernel.raise ::Despecable::InvalidParameterError, "Invalid value for param: '#{name}'. Required type: integer." if int.to_s != params[name].sub(/^0+/, "")
      params[name] = int
    end

    def coerce_string(name)
      # This is really a no-op.
      params[name] = params[name].to_s
    end

    def coerce_boolean(name)
      case params[name].to_s
      when "true", "1" then params[name] = true
      when "false", "0", nil then params[name] = false
      else ::Kernel.raise ::Despecable::InvalidParameterError, "Invalid value for param: '#{name}'. Require type: boolean (1/0 or true/false)"
      end
    end

    def coerce_date(name)
      date = params[name] &&::Date.rfc3339(params[name] + "T00:00:00+00:00") rescue nil
      ::Kernel.raise ::Despecable::InvalidParameterError, "Invalid value for param: '#{name}'. Required type: date (e.g. '2012-12-31')." if params.key(name) && date.nil?
      params[name] = date
    end

    def coerce_datetime(name)
      date = params[name] &&::DateTime.rfc3339(params[name]) rescue nil
      ::Kernel.raise ::Despecable::InvalidParameterError, "Invalid value for param: '#{name}'. Required type: rfc3339 datetime (e.g. 2012-12-31T19:00:00-05:00')" if params.key(name) && date.nil?
      params[name] = date
    end
  end
end
