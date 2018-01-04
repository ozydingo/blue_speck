class Despecable::UnrecognizedParameterError < Despecable::DespecableError
  def introduction(name)
    "Unrecognized parameter name: '#{name}'"
  end
end
