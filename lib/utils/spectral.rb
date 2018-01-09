module Despecable
  module Spectral
    def despecabled
      @_despeecabled ||= []
    end

    # Hijack the `despec` method to gather info
    def despec(*args, strict: false, &blk)
      @_despeecabled = despecabled + Despecable::Spectrogram.new.instance_exec(&blk)
      # Slightly less thorough, much more safe: guarantee that we stop after the despec block
      raise Despecable::SpectacularError, "despec stop!"
    end

    alias_method :despec!, :despec
  end
end
