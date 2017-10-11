class Despecable::MissingParameterError < Despecable::DespecableError
  def intro_message(name)
    "Missing required parameter '#{name}'."
  end
end
