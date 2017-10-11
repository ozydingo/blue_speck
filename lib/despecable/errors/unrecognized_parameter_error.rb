class Despecable::UnrecognizedParameterError < Despecable::DespecableError
  def intro_message(name)
    "Unrecognized parameter name: '#{name}'"
  end
end
