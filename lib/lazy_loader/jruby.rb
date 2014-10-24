# -*- encoding: utf-8 -*-

require 'java'
require 'tempfile'

module LazyLoader

  def self._create_lazy_loader(&b)
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

  def self._compile_and_require_java_sources(java_source_dir_path)
    java_out = Dir.mktmpdir
    java_source_paths = Dir.entries(java_source_dir_path).select do |java_source_path|
      java_source_path =~ /\.java$/
    end.map do |java_source_path|
      File.expand_path(File.join(java_source_dir_path, java_source_path))
    end
    javac_cmd = "javac -d #{java_out} #{java_source_paths.join(' ')}"
    rc = system(javac_cmd)
    raise StandardError.new("#{javac_cmd}: #{$?.exitstatus.to_s}") unless rc
    $CLASSPATH << java_out
  end

  _compile_and_require_java_sources(File.join(File.dirname(__FILE__), '../../ext/java/src/com/centzy/lazyloader'))
end
