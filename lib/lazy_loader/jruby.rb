# -*- encoding: utf-8 -*-

require 'java'
require 'tempfile'

module LazyLoader

  _compile_and_require_java_sources(File.join(File.dirname(__FILE__), '../ext/java/src/com/centzy/lazyloader'))

  # Create a new lazy loader.
  #
  # The returned object will have a #get method on it, which will only
  # execute the specified block once, but always return the value
  # returned from the specified block.
  #
  # This delegates to a Java class that uses double locking and a volatile variable.
  #
  # @param [Proc] b the block
  # @return [Object] a new lazy loader
  def self.create_lazy_loader(&b)
    DelegatingLazyLoader.new(b)
  end

  ### private ###

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

  def self._compile_and_require_java_sources(java_source_dir_path)
    java_out = Dir.mktmpdir
    java_source_paths = Dir.entries(java_source_dir_path).select do |java_source_path|
      java_source_path =~ /\.java$/
    end.map do |java_source_path|
      File.expand_path(File.join(java_source_dir_path), java_source_path)
    end
    javac_cmd = "javac -d #{java_out} #{java_source_paths.join(' ')}"
    rc = system(javac_cmd)
    raise StandardError.new("#{javac_cmd}: #{$?.exitstatus.to_s}") unless rc
    $CLASSPATH << java_out
  end
end
