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

class Class
  alias :original_new :new

  def new(*args, &block)
    obj = original_new(*args, &block)
    if !__symbol_to_lazy_reader_lazy_loader_create_lambda__.empty?
      obj.instance_variable_set(
        :@__symbol_to_lazy_reader_lazy_loader__,
        __symbol_to_lazy_reader_lazy_loader_create_lambda__.inject(Hash.original_new) do |hash, (symbol, lazy_reader_lazy_loader_create_lambda)|
          hash[symbol] = lazy_reader_lazy_loader_create_lambda.call(obj)
          hash
        end
      )
    end
    obj
  end

  def __symbol_to_lazy_reader_lazy_loader_create_lambda__
    @__symbol_to_lazy_reader_lazy_loader_create_lambda__ ||= Hash.original_new
  end

  def lazy_reader(*symbols)
    symbols.each do |symbol|
      class_eval <<-EOF, __FILE__, __LINE__ + 1
        __symbol_to_lazy_reader_lazy_loader_create_lambda__[:#{symbol}] = lambda do |instance|
          LazyLoader.create_lazy_loader do
            raise StandardError.new("You must define load_#{symbol} for \#{instance.class.name}") unless instance.respond_to?(:load_#{symbol})
            instance.load_#{symbol}
          end
        end

        def #{symbol}
          @__symbol_to_lazy_reader_lazy_loader__[:#{symbol}].get
        end
      EOF
    end
  end
end
