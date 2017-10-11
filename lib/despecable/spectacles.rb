module Despecable
  class Spectacles
    attr_reader :params
    
    def initialize(params)
      @params = params
    end

    def validate_param(name, options)
      validate_param_presence(name) if options[:required]
      validate_param_value(name, options[:in]) if options.key?(:in) && params.key?(name)
    end

    def validate_param_presence(name)
      raise Despecable::MissingParameterError, "Missing required param: '#{name}'" if !params.key?(name)
    end

    def validate_param_value(name, allowed_values)
      raise Despecable::IncorrectParameterError, "Incorrect value for param: '#{name}'" if !allowed_values.include?(params[name])
    end

    def integer(name)
      int = params[name].to_i
      raise Despecable::InvalidParameterError, "Invalid value for param: '#{name}'. Required type: integer." if int.to_s != params[name].sub(/^0+/, "")
      return int
    end

    def string(name)
      # This is really a no-op.
      params[name].to_s
    end

    def boolean(name)
      case params[name].to_s
      when "true", "1" then true
      when "false", "0", nil then false
      else raise Despecable::InvalidParameterError, "Invalid value for param: '#{name}'. Require type: boolean (1/0 or true/false)"
      end
    end

    def date(name)
      date = params[name] && Date.rfc3339(params[name] + "T00:00:00+00:00") rescue nil
      raise Despecable::InvalidParameterError, "Invalid value for param: '#{name}'. Required type: date (e.g. '2012-12-31')." if params.key(name) && date.nil?
      return date
    end

    def datetime(name)
      date = params[name] && DateTime.rfc3339(params[name]) rescue nil
      raise Despecable::InvalidParameterError, "Invalid value for param: '#{name}'. Required type: rfc3339 datetime (e.g. 2012-12-31T19:00:00-05:00')" if params.key(name) && date.nil?
      return date
    end
  end
end
