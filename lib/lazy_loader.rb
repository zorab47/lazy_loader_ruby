# -*- encoding: utf-8 -*-

if RUBY_PLATFORM =~ /java/
  require 'java'
  $CLASSPATH << File.expand_path(File.join(File.dirname(__FILE__), "../ext/java/out"))
end

require 'lazy_loader/version'

module LazyLoader

  def self.create_lazy_loader(&b)
    send(CREATE_METHOD_NAME, b)
  end

  private

  CREATE_METHOD_NAME = RUBY_PLATFORM =~ /java/ ? :_create_java_lazy_loader : :_create_mri_lazy_loader

  def self._create_java_lazy_loader(b)
    com.centzy.util.concurrent.LazyLoader.new(CallableImpl.new(b))
  end

  def self._create_mri_lazy_loader(b)
    MriLazyLoader.new(b)
  end

  if RUBY_PLATFORM =~ /java/
    class CallableImpl
      include java.util.concurrent.Callable
      def initialize(b)
        @b = b
      end
      def call
        @b.call.freeze
      end
    end
  end

  class MriLazyLoader
    def initialize(b)
      @b = b
    end
    def get
      @value ||= @b.call.freeze
      @value
    end
  end
end
