module Despecable
  module ActionController
    def despec(&blk)
      Despecable::Me.new(params.deep_dup).doit(&blk)
    end

    def despec!(&blk)
      Despecable::Me.new(params).doit(&blk)
    end
  end
end
