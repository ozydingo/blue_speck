class Despecable::DespecableError < StandardError
  def despecable_message
    message == self.class.to_s ? nil : message
  end

  def insert_name_here(name)
    msg = introduction(name)
    msg += " " + despecable_message unless despecable_message.nil?
    return exception(msg)
  end

  def introduction(name)
    "Invalid value for paramter #{name}."
  end
end
