module Despecable
  class Spectacles
    def arrayable?(value)
      value.is_a?(::Array) || /,/ =~ value.to_s
    end

    def arrayify(value)
      return value if value.is_a?(Array)
      value.to_s.split(",")
    end

    def read(value, type, options)
      value = public_send(type, value) unless value.nil?
      validate_param(value, options)
      return value
    end

    def validate_param(value, options)
      validate_param_presence(value) if options[:required]
      validate_param_value(value, options[:in]) if options.key?(:in) && !value.nil?
    end

    def validate_param_presence(value)
      raise Despecable::MissingParameterError if value.nil?
    end

    def validate_param_value(value, allowed_values)
      raise Despecable::IncorrectParameterError, "Value received: #{value}." if !allowed_values.include?(value)
    end

    def integer(value)
      Integer(value)
    rescue ArgumentError
      raise unless /^invalid value for Integer/ =~ $!.message
      raise Despecable::InvalidParameterError, "Required type: integer"
    end

    def float
      Float(value)
    rescue ArgumentError
      raise unless /^invalid value for Float/ =~ $!.message
      raise Despecable::InvalidParameterError, "Required type: float"
    end

    def string(value)
      # This is really a no-op.
      value.to_s
    end

    def boolean(value)
      case value.to_s
      when "true", "1" then true
      when "false", "0", nil then false
      else raise Despecable::InvalidParameterError, "Required type: boolean (1/0 or true/false)"
      end
    end

    def date(value)
      Date.rfc3339(value + "T00:00:00+00:00")
    rescue ArgumentError
      raise unless $!.message == "invalid date"
      raise Despecable::InvalidParameterError, "Required type: date (e.g. '2012-12-31')."
    end

    def datetime(value)
      DateTime.rfc3339(value)
    rescue ArgumentError
      raise unless $!.message == "invalid date"
      raise Despecable::InvalidParameterError, "Required type: rfc3339 datetime (e.g. '2009-06-19T00:00:00-04:00')."
    end

    def file(value)
      raise Despecable::InvalidParameterError, "Required type: file upload" if !(value.respond_to?(:original_filename) && value.original_filename.present?)
      return value
    end

    def any(value)
      value
    end
  end
end
