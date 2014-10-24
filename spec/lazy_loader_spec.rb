# -*- encoding: utf-8 -*-

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "lib"))
require 'lazy_loader'

describe LazyLoader do

  it "performs basic operations" do
    i = 0
    lazy_load = LazyLoader.create_lazy_loader do
      i += 1
      i
    end

    expect(lazy_load.get).to eq(1)
    expect(lazy_load.get).to eq(1)
  end

  it "performs basic operations with threads" do
    i = 0
    lazy_load = LazyLoader.create_lazy_loader do
      i += 1
      i
    end

    (1..200).map do |_|
      Thread.new do
        sleep(0.0001 * Random.rand(1000))
        expect(lazy_load.get).to eq(1)
      end
    end.shuffle.each do |thread|
      thread.join
    end
  end

  it "allows nil" do
    lazy_load = LazyLoader.create_lazy_loader do
      nil
    end

    expect(lazy_load.get).to be_nil
  end

  it "allows nil each time" do
    lazy_load = LazyLoader.create_lazy_loader do
      nil
    end

    (1..200).map do |_|
      Thread.new do
        sleep(0.0001 * Random.rand(1000))
        expect(lazy_load.get).to eq(nil)
      end
    end.shuffle.each do |thread|
      thread.join
    end
  end

  it "does not throw error on false" do
    lazy_load = LazyLoader.create_lazy_loader do
      false
    end
    expect(lazy_load.get).to eq(false)
  end

  it "does not throw error on false with threads" do
    lazy_load = LazyLoader.create_lazy_loader do
      false
    end

    (1..200).map do |_|
      Thread.new do
        sleep(0.0001 * Random.rand(1000))
        expect(lazy_load.get).to eq(false)
      end
    end.shuffle.each do |thread|
      thread.join
    end
  end

  it "throws an error" do
    lazy_load = LazyLoader.create_lazy_loader do
      raise StandardError.new("test_message")
    end

    expect(proc { lazy_load.get }).to raise_error(StandardError) do |e|
      expect(e.message).to match(/test_message/)
    end
  end

  it "throws an error each time" do
    i = 0
    lazy_load = LazyLoader.create_lazy_loader do
      i += 1
      raise StandardError.new("test_message#{i}")
    end

    (1..200).map do |_|
      Thread.new do
        sleep(0.0001 * Random.rand(1000))
        expect(proc { lazy_load.get }).to raise_error(StandardError) do |e|
          expect(e.message).to match(/test_message1/)
        end
      end
    end.shuffle.each do |thread|
      thread.join
    end
  end

  it "works when LazyLoader is included in a class" do
    i = 0
    lazy_load = IncludeLazyLoader.new.create do
      i += 1
      i
    end

    expect(lazy_load.get).to eq(1)
    expect(lazy_load.get).to eq(1)
  end

  it "works when LazyLoader is self included in a class" do
    i = 0
    lazy_load = SelfIncludeLazyLoader.create do
      i += 1
      i
    end

    expect(lazy_load.get).to eq(1)
    expect(lazy_load.get).to eq(1)
  end
end
