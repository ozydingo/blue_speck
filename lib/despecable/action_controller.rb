module Despecable
  module ActionController
    def despec(&blk)
      reader = Despecable::Reader.new(params)
      reader.instance_eval(&blk)
      return reader.params
    end
  end
end
