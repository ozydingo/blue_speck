module Despecable
  class Spectacles
    def arrayable?(value)
      value.is_a?(::Array) || /,/ =~ value.to_s
    end

    def arrayify(value)
      return value if value.is_a?(Array)
      value.to_s.split(",")
    end

    def read(name, value, type, options, &blk)
      value = public_send(type, name, value, options, &blk) unless value.nil?
      validate_param(name, value, options)
      return value
    end

    def validate_param(name, value, options)
      validate_param_value(name, value, options) if options.key?(:in) && !value.nil?
    end

    def validate_param_value(name, value, options)
      allowed_values = options[:in]
      allowed_values = allowed_values.map{|x| x.is_a?(String) ? x.downcase : x} if options[:case] == false
      value = value.downcase if options[:case] == false && value.is_a?(String)
      if !allowed_values.include?(value)
        msg = "Unacceptable value for parameter: '#{name}'"
        allowed_values_message = expected_values_message(allowed_values)
        msg += "; acceptable values are" + allowed_values_message if !allowed_values_message.nil?
        raise Despecable::IncorrectParameterError.new(msg, parameters: name)
      end
    end

    def validate_string_length(name, value, options)
      allowed_lengths = options[:length]
      allowed_lengths = [*allowed_lengths] unless allowed_lengths.is_a?(Range)
      if !allowed_lengths.include?(value.length)
        msg = "Unacceptable length for parameter: '#{name}'"
        allowed_values_message = expected_values_message(allowed_lengths)
        msg += "; acceptable lengths are" + allowed_values_message if !allowed_values_message.nil?
        raise Despecable::IncorrectParameterError.new(msg, parameters: name)
      end
    end

    def expected_values_message(allowed_values)
      case allowed_values
      when Array
        msg = ": " + allowed_values.slice(0..99).join(", ")
        msg += ", ... [truncated]" if allowed_values.length > 100
        return msg
      when Range
        " between #{allowed_values.first} and #{allowed_values.last}"
      else
        nil
      end
    end

    def integer(name, value, options)
      Integer(value)
    rescue ArgumentError
      raise unless /^invalid value for Integer/ =~ $!.message
      raise Despecable::InvalidParameterError.new("Integer type required for parameter: '#{name}'", parameters: name)
    end

    def float(name, value, options)
      Float(value)
    rescue ArgumentError
      raise unless /^invalid value for Float/ =~ $!.message
      raise Despecable::InvalidParameterError.new("Float type required for parameter: '#{name}'", parameters: name)
    end

    def string(name, value, options)
      value = value.to_s #no-op
      validate_string_length(name, value, options) if options.key?(:length)
      return value
    end

    def boolean(name, value, options)
      case value.to_s
      when "true", "1" then true
      when "false", "0", nil then false
      else raise Despecable::InvalidParameterError.new("Boolean type (1/0 or true/false) required for parameter: '#{name}'", parameters: name)
      end
    end

    def date(name, value, options)
      Date.rfc3339(value + "T00:00:00+00:00")
    rescue ArgumentError
      raise unless $!.message == "invalid date"
      raise Despecable::InvalidParameterError.new("Date type (e.g. '2012-12-31') required for parameter: '#{name}'", parameters: name)
    end

    def datetime(name, value, options)
      DateTime.rfc3339(value)
    rescue ArgumentError
      raise unless $!.message == "invalid date"
      raise Despecable::InvalidParameterError.new("Rfc3339 datetime type (e.g. '2009-06-19T00:00:00-04:00') required for parameter: '#{name}'", parameters: name)
    end

    def file(name, value, options)
      raise Despecable::InvalidParameterError.new("File upload type required for parameter: '#{name}'" , parameters: name) if !(value.respond_to?(:original_filename) && value.original_filename.to_s.length > 0)
      return value
    end

    def any(name, value, options)
      value
    end

    def custom(name, value, options)
      return yield(name, value, options)
    end
  end
end
