# -*- encoding: utf-8 -*-

module LazyLoader

  # Create a new lazy loader.
  #
  # The returned object will have a #get method on it, which will only
  # execute the specified block once, but always return the value
  # returned from the specified block.
  #
  # This uses ||=.
  #
  # @param [Proc] b the block
  # @return [Object] a new lazy loader
  def self.create_lazy_loader(&b)
    OrEqualsLazyLoader.new(b)
  end

  ### private ###

  class OrEqualsLazyLoader
    def initialize(b)
      @b = b
    end
    def get
      @value ||= ObjectWrapper.new(@b)
      @value.get_wrapped_object
    end
  end

  # This is so we can have nil objects
  class ObjectWrapper
    def initialize(b)
      begin
        @o = b.call.freeze
        @e = nil
      rescue StandardError => e
        @o = nil
        @e = e
      end
    end
    def get_wrapped_object
      raise @e if @e != nil
      @o
    end
  end
end
