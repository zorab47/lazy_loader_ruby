# -*- encoding: utf-8 -*-

require 'lazy_loader/version'

case RUBY_ENGINE.to_sym
when :jruby then require 'lazy_loader/jruby'
when :mri then require 'lazy_loader/mri'
else raise StandardError.new("LazyLoader is only usable for JRuby (RUBY_ENGINE=jruby) and MRI Ruby (RUBY_ENGINE=mri), RUBY_ENGINE is #{RUBY_ENGINE.to_sym}")
end

module LazyLoader

  # Create a new lazy loader.
  #
  # The returned object will have a #get method on it, which will only
  # execute the specified block once, but always return the value
  # returned from the specified block.
  #
  # In JRuby, this delegates to a Java class that uses double locking and a volatile variable.
  # In MRI Ruby, this uses ||=.
  #
  # @param [Proc] b the block
  # @return [Object] a new lazy loader
  def self.create_lazy_loader(&b)
    _create_lazy_loader(&b)
  end

  def create_lazy_loader(&b)
    LazyLoader.create_lazy_loader(&b)
  end
end
