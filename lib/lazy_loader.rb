# -*- encoding: utf-8 -*-

require 'lazy_loader/version'

module LazyLoader
  if RUBY_PLATFORM =~ /java/
    require 'java'
    $CLASSPATH << File.expand_path(File.join(File.dirname(__FILE__), "../ext/java/out"))

    # Create a new lazy loader.
    #
    # The returned object will have a #get method on it, which will only
    # execute the specified block once, but always return the value
    # returned from the specified block.
    #
    # If in JRuby, this delegates to a Java class that uses double locking
    # and a volatile variable. Otherwise, this uses ||=.
    #
    # @param [Proc] b the block
    # @return [Object] a new lazy loader
    def self.create_lazy_loader(&b)
      com.centzy.util.concurrent.LazyLoader.new(CallableImpl.new(b))
    end

    class CallableImpl
      include java.util.concurrent.Callable
      def initialize(b)
        @b = b
      end
      def call
        value = @b.call.freeze
        raise StandardError.new("nil object") if value == nil
        value
      end
    end
  else
    def self.create_lazy_loader(&b)
      OrEqualsLazyLoader.new(b)
    end

    class OrEqualsLazyLoader
      def initialize(b)
        @b = b
      end
      def get
        @value ||= @b.call.freeze
        raise StandardError.new("nil object") if @value == nil
        @value
      end
    end
  end
end
