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
