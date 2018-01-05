class Despecable::DespecableError < StandardError
  attr_accessor :parameters
  protected :parameters=

  def initialize(*args, parameters: [])
    @parameters = [*parameters].map(&:to_s)
    super(*args)
  end

  def exception(*args)
    ex = super
    ex.parameters = @parameters
    return ex
  end
end
