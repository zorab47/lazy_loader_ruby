# -*- encoding: utf-8 -*-

module LazyLoader

  def self._create_lazy_loader(&b)
    OrEqualsLazyLoader.new(b)
  end

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
