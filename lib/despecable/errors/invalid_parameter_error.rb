class Despecable::InvalidParameterError < Despecable::DespecableError
  def introduction(name)
    "Invalid value for parameter '#{name}'."
  end
end
