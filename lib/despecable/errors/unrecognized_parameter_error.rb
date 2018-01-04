class Despecable::UnrecognizedParameterError < Despecable::DespecableError
  def introduction(name)
    "Unrecognized parameter '#{name}'"
  end
end
