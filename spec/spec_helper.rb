# -*- encoding: utf-8 -*-

require 'rspec'
require 'simplecov'
SimpleCov.start

require 'lazy_loader'

class IncludeLazyLoader
  include LazyLoader

  def create(&b)
    create_lazy_loader(&b)
  end
end

class SelfIncludeLazyLoader
  class << self
    include LazyLoader
  end

  def self.create(&b)
    create_lazy_loader(&b)
  end
end

class ExtendLazyLoader
  extend LazyLoader

  def create(&b)
    create_lazy_loader(&b)
  end
end

class SelfExtendLazyLoader
  extend LazyLoader

  def self.create(&b)
    create_lazy_loader(&b)
  end
end


class LazyRead

  lazy_reader :foo, :bar

  def initialize(foo_seed, bar_seed)
    @foo_seed = foo_seed
    @bar_seed = bar_seed
  end

  def load_foo
    @foo_seed += 1
    @foo_seed
  end

  def load_bar
    @bar_seed += 1
    @bar_seed
  end
end

class LazyReadTwo

  lazy_reader :foo, :bar

  def initialize(foo_seed, bar_seed)
    @foo_seed = foo_seed
    @bar_seed = bar_seed
  end

  def load_foo
    @foo_seed += 2
    @foo_seed
  end

  def load_bar
    @bar_seed += 2
    @bar_seed
  end
end

class LazyReadChild < LazyRead
end
