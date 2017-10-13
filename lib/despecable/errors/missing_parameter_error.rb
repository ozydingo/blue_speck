class Despecable::MissingParameterError < Despecable::DespecableError
  def introduction(name)
    "Missing required parameter '#{name}'."
  end
end
