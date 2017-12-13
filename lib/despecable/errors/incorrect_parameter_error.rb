class Despecable::IncorrectParameterError < Despecable::DespecableError
  def introduction(name)
    "Incorrect value for parameter '#{name}'."
  end
end
