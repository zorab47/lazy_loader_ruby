# -*- encoding: utf-8 -*-

require 'lazy_loader/version'

module LazyLoader
  if RUBY_ENGINE == 'jruby'
    require 'java'
    $CLASSPATH << File.expand_path(File.join(File.dirname(__FILE__), "../ext/java/out"))

    # Create a new lazy loader.
    #
    # The returned object will have a #get method on it, which will only
    # execute the specified block once, but always return the value
    # returned from the specified block.
    #
    # If in JRuby, this delegates to a Java class that uses double locking
    # and a volatile variable. In MRI Ruby, this uses ||=.
    #
    # @param [Proc] b the block
    # @return [Object] a new lazy loader
    def self.create_lazy_loader(&b)
      DelegatingLazyLoader.new(b)
    end

    class DelegatingLazyLoader
      def initialize(b)
        @delegate = com.centzy.lazyloader.LazyLoaderDelegate.new(CallableImpl.new(b))
      end
      def get
        result = @delegate.get
        begin
          result.get_wrapped_object
        rescue com.centzy.lazyloader.LazyLoaderException => e
          raise StandardError.new(e.get_message)
        end
      end
    end

    class CallableImpl
      include java.util.concurrent.Callable
      def initialize(b)
        @b = b
      end
      def call
        ObjectWrapper.new(@b.call.freeze)
      end
    end

    # This needs to be done so that JRuby doesn't convert certain objects,
    # i.e. Strings encoded with Encoding::BINARY
    class ObjectWrapper
      def initialize(o)
        @o = o
      end
      def get_wrapped_object
        @o
      end
    end
  elsif RUBY_ENGINE == 'ruby'
    def self.create_lazy_loader(&b)
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
  else
    raise StandardError.new("LazyLoader is only usable for JRuby and Ruby (are you using Rubinus?)")
  end
end
