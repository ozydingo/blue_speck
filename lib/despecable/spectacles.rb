module Despecable
  class Spectacles
    def arrayable?(value)
      value.is_a?(::Array) || /,/ =~ value.to_s
    end

    def arrayify(value)
      return value if value.is_a?(Array)
      value.to_s.split(",")
    end

    def read(name, value, type, options)
      value = public_send(type, name, value) unless value.nil?
      validate_param(name, value, options)
      return value
    end

    def validate_param(name, value, options)
      validate_param_presence(name, value) if options[:required]
      validate_param_value(name, value, options[:in]) if options.key?(:in) && !value.nil?
    end

    def validate_param_presence(name, value)
      raise Despecable::MissingParameterError.new("Missing required parameter: #{name}", parameters: name) if value.nil?
    end

    def validate_param_value(name, value, allowed_values)
      raise Despecable::IncorrectParameterError.new("Unacceptable value for parameter: #{name}", parameters: name) if !allowed_values.include?(value)
    end

    def integer(name, value)
      Integer(value)
    rescue ArgumentError
      raise unless /^invalid value for Integer/ =~ $!.message
      raise Despecable::InvalidParameterError.new("Integer type required for parameter: #{name}", parameters: name)
    end

    def float(name, value)
      Float(value)
    rescue ArgumentError
      raise unless /^invalid value for Float/ =~ $!.message
      raise Despecable::InvalidParameterError.new("Float type required for parameter: #{name}", parameters: name)
    end

    def string(name, value)
      # This is really a no-op.
      value.to_s
    end

    def boolean(name, value)
      case value.to_s
      when "true", "1" then true
      when "false", "0", nil then false
      else raise Despecable::InvalidParameterError.new("Boolean type (1/0 or true/false) required for parameter: #{name}", parameters: name)
      end
    end

    def date(name, value)
      Date.rfc3339(value + "T00:00:00+00:00")
    rescue ArgumentError
      raise unless $!.message == "invalid date"
      raise Despecable::InvalidParameterError.new("Date type (e.g. '2012-12-31') required for parameter: #{name}", parameters: name)
    end

    def datetime(name, value)
      DateTime.rfc3339(value)
    rescue ArgumentError
      raise unless $!.message == "invalid date"
      raise Despecable::InvalidParameterError.new("Rfc3339 datetime type (e.g. '2009-06-19T00:00:00-04:00') required for parameter: #{name}", parameters: name)
    end

    def file(name, value)
      raise Despecable::InvalidParameterError.new("File upload type required for parameter: #{name}" , parameters: name) if !(value.respond_to?(:original_filename) && value.original_filename.present?)
      return value
    end

    def any(name, value)
      value
    end
  end
end
