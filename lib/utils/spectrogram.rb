module Despecable
  class Spectrogram
    (::Despecable::Spectator.instance_methods(false) - [:specd]).each do |method|
      define_method(method) do |name, options = {}|
        _spec(name, method, options)
      end
    end

    def despecabled
      @_despeecabled ||= []
    end

    private

    def _spec(name, type, options = {})
      despecabled << {
        name: name,
        type: type,
      }.merge(options)
    end
  end
end
