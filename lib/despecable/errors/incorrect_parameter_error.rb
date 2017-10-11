class Despecable::IncorrectParameterError < Despecable::DespecableError
  def introduction(name)
    "Incorrect value for paramter '#{name}'."
  end
end
